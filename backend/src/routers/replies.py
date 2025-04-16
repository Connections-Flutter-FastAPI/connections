# backend/routers/replies.py
from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Optional
import psycopg2

from .. import schemas, crud, auth
from ..database import get_db_connection

router = APIRouter(
    prefix="/replies",
    tags=["Replies"],
)

@router.post("", status_code=status.HTTP_201_CREATED, response_model=schemas.ReplyDisplay)
async def create_reply(
    reply_data: schemas.ReplyCreate,
    current_user_id: int = Depends(auth.get_current_user)
):
    """Creates a new reply to a post."""
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Optional: Validate parent_reply_id exists and belongs to the same post_id
        if reply_data.parent_reply_id:
            parent = crud.get_reply_by_id(cursor, reply_data.parent_reply_id)
            if not parent:
                 raise HTTPException(status_code=400, detail="Parent reply ID does not exist.")
            if parent['post_id'] != reply_data.post_id:
                 raise HTTPException(status_code=400, detail="Parent reply belongs to a different post.")

        reply_id = crud.create_reply_db(
            cursor,
            post_id=reply_data.post_id,
            user_id=current_user_id,
            content=reply_data.content,
            parent_reply_id=reply_data.parent_reply_id
        )
        if reply_id is None:
             raise HTTPException(status_code=500, detail="Reply creation failed")

        # Fetch the created reply details for the response
        # Need a more detailed fetch or construct manually
        cursor.execute( # Fetch again with joins for author info
             """
             SELECT r.*, u.username AS author_name, u.image_path AS author_avatar,
                    0 AS upvotes, 0 AS downvotes -- Placeholder counts for new reply
             FROM replies r JOIN users u ON r.user_id = u.id WHERE r.id = %s
             """, (reply_id,)
        )
        created_reply_db = cursor.fetchone()
        conn.commit()

        if not created_reply_db:
              raise HTTPException(status_code=500, detail="Could not retrieve created reply")

        print(f"✅ Reply {reply_id} created by User {current_user_id} for Post {reply_data.post_id}")
        return schemas.ReplyDisplay(**created_reply_db) # Validate against schema

    except psycopg2.Error as e:
        if conn: conn.rollback()
        print(f"❌ Database Error creating reply: {e}")
        detail = f"Database error: {e.pgerror}"
        if e.pgcode == '23503': # Foreign key violation
             detail = "Invalid post_id or parent_reply_id provided."
        raise HTTPException(status_code=400, detail=detail)
    except HTTPException as http_exc:
         if conn: conn.rollback()
         raise http_exc
    except Exception as e:
        if conn: conn.rollback()
        print(f"❌ Unexpected Error creating reply: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if conn: conn.close()

@router.get("/{post_id}", response_model=List[schemas.ReplyDisplay])
async def get_replies_for_post(post_id: int):
    """Fetches all replies for a specific post."""
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        replies_db = crud.get_replies_for_post_db(cursor, post_id)
        print(f"✅ Fetched {len(replies_db)} replies for post {post_id}")
        # Pydantic validates list items
        # TODO: Add user vote status if needed
        return replies_db
    except Exception as e:
        print(f"❌ Error fetching replies for post {post_id}: {e}")
        raise HTTPException(status_code=500, detail="Error fetching replies")
    finally:
        if conn: conn.close()

@router.delete("/{reply_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_reply(
    reply_id: int,
    current_user_id: int = Depends(auth.get_current_user)
):
    """Deletes a reply (only author can delete)."""
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        # Check ownership
        reply = crud.get_reply_by_id(cursor, reply_id)
        if not reply:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Reply not found")
        if reply["user_id"] != current_user_id:
             raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to delete this reply")

        rows_deleted = crud.delete_reply_db(cursor, reply_id)
        conn.commit()

        if rows_deleted == 0:
             print(f"⚠️ Reply {reply_id} not found during delete.")
             raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Reply not found")

        print(f"✅ Reply {reply_id} deleted by User {current_user_id}")
        return None

    except HTTPException as http_exc:
         if conn: conn.rollback()
         raise http_exc
    except Exception as e:
        if conn: conn.rollback()
        print(f"❌ Error deleting reply {reply_id}: {e}")
        raise HTTPException(status_code=500, detail="Could not delete reply")
    finally:
        if conn: conn.close()


# --- Reply Favorites ---
@router.post("/{reply_id}/favorite", status_code=status.HTTP_200_OK)
async def favorite_reply(
    reply_id: int,
    current_user_id: int = Depends(auth.get_current_user)
):
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        fav_id = crud.add_reply_favorite_db(cursor, current_user_id, reply_id)
        conn.commit()
        if fav_id:
            return {"message": "Reply favorited"}
        else:
            return {"message": "Reply already favorited or invalid ID"}
    except psycopg2.Error as e:
        if conn: conn.rollback()
        if e.pgcode == '23503': # FK violation
             raise HTTPException(status_code=404, detail="Reply not found")
        raise HTTPException(status_code=500, detail="Database error")
    finally:
        if conn: conn.close()

@router.delete("/{reply_id}/unfavorite", status_code=status.HTTP_200_OK)
async def unfavorite_reply(
    reply_id: int,
    current_user_id: int = Depends(auth.get_current_user)
):
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        deleted_id = crud.remove_reply_favorite_db(cursor, current_user_id, reply_id)
        conn.commit()
        if deleted_id:
            return {"message": "Reply unfavorited"}
        else:
            return {"message": "Reply was not favorited"}
    except Exception as e:
        if conn: conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if conn: conn.close()
