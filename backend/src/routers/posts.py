# backend/routers/posts.py
from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Optional
import psycopg2

from .. import schemas, crud, auth # Relative imports
from ..database import get_db_connection

router = APIRouter(
    prefix="/posts",
    tags=["Posts"],
)

@router.post("", status_code=status.HTTP_201_CREATED, response_model=schemas.PostDisplay) # Use PostDisplay for response
async def create_post(
    post_data: schemas.PostCreate,
    current_user_id: int = Depends(auth.get_current_user)
):
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        post_id = crud.create_post_db(
            cursor,
            user_id=current_user_id,
            title=post_data.title,
            content=post_data.content,
            community_id=post_data.community_id
        )
        if post_id is None:
             raise HTTPException(status_code=500, detail="Post creation failed")

        # Fetch the created post to return details matching PostDisplay
        # This might involve another query or refining create_post_db
        created_post_db = crud.get_post_by_id(cursor, post_id) # Need a get_post_by_id in crud
        if not created_post_db:
             # This shouldn't happen if insert succeeded, but handle defensively
             raise HTTPException(status_code=500, detail="Could not retrieve created post")

        conn.commit()

         # Fetch user info for author details (or join in get_post_by_id)
        user_info = crud.get_user_by_id(cursor, current_user_id)
        author_name = user_info['username'] if user_info else 'Unknown'
        author_avatar = user_info['image_path'] if user_info else None


        # Manually construct the response object if get_post_by_id doesn't have all fields
        response_data = {
             **created_post_db, # Include fields from the post table
             "author_name": author_name,
             "author_avatar": author_avatar,
             "upvotes": 0, # Default values for a new post
             "downvotes": 0,
             "reply_count": 0,
             "community_id": post_data.community_id, # Add community ID back
             # "community_name": ... # Need to fetch community name if community_id exists
        }


        print(f"✅ Post created with ID: {post_id}, linked to community: {post_data.community_id}")
        # Return data conforming to PostDisplay
        return schemas.PostDisplay(**response_data)

    except psycopg2.Error as e:
        if conn: conn.rollback()
        print(f"❌ SQL Error creating post: {e.pgcode} - {e.pgerror}")
        raise HTTPException(status_code=400, detail=f"Database error: {e.pgerror}")
    except Exception as e:
        if conn: conn.rollback()
        print(f"❌ Unexpected Error creating post: {repr(e)}")
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if conn: conn.close()


@router.get("", response_model=List[schemas.PostDisplay]) # Response is a list of posts
async def get_posts(
    community_id: Optional[int] = None,
    user_id: Optional[int] = None
    # Add pagination params: skip: int = 0, limit: int = 20
):
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        posts_db = crud.get_posts_db(cursor, community_id=community_id, user_id=user_id) # Add skip, limit
        # Convert POINT strings if necessary before validation
        # posts_processed = []
        # for post in posts_db:
        #     # Add processing if needed, e.g., formatting location
        #     posts_processed.append(post)
        print(f"✅ Fetched {len(posts_db)} posts")
        # Pydantic will validate each item in the list against PostDisplay
        return posts_db
    except Exception as e:
        print(f"❌ Error fetching posts: {e}")
        raise HTTPException(status_code=500, detail="Error fetching posts")
    finally:
        if conn: conn.close()


@router.get("/trending", response_model=List[schemas.PostDisplay])
async def get_trending_posts():
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        posts_db = crud.get_trending_posts_db(cursor)
        print(f"✅ Fetched {len(posts_db)} trending posts")
        return posts_db # Pydantic validates list items
    except Exception as e:
        print(f"❌ Error fetching trending posts: {e}")
        raise HTTPException(status_code=500, detail="Error fetching trending posts")
    finally:
        if conn: conn.close()

@router.delete("/{post_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_post(
    post_id: int,
    current_user_id: int = Depends(auth.get_current_user)
):
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Check ownership before deleting
        post = crud.get_post_by_id(cursor, post_id) # Fetch the post first
        if not post:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Post not found")
        if post["user_id"] != current_user_id:
             raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to delete this post")

        rows_deleted = crud.delete_post_db(cursor, post_id)
        conn.commit()

        if rows_deleted == 0:
             # This case should be caught by the check above, but good to have
             print(f"⚠️ Post {post_id} not found for deletion (already checked).")
             raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Post not found")

        print(f"✅ Post {post_id} deleted successfully")
        return None # Return None for 204 No Content

    except HTTPException as http_exc:
         if conn: conn.rollback()
         raise http_exc
    except psycopg2.Error as e:
        if conn: conn.rollback()
        print(f"❌ SQL Error deleting post {post_id}: {e}")
        raise HTTPException(status_code=500, detail="Database error during deletion")
    except Exception as e:
        if conn: conn.rollback()
        print(f"❌ Unexpected Error deleting post {post_id}: {e}")
        raise HTTPException(status_code=500, detail="Could not delete post")
    finally:
        if conn: conn.close()


# --- TODO: Implement routers/communities.py, routers/replies.py etc. similarly ---
# --- Example: routers/communities.py (Partial) ---
# from fastapi import APIRouter, Depends, HTTPException, status
# from typing import List, Optional
# import psycopg2
# from .. import schemas, crud, auth, utils
# from ..database import get_db_connection

# router = APIRouter(prefix="/communities", tags=["Communities"])

# @router.post("", status_code=status.HTTP_201_CREATED, response_model=schemas.CommunityDisplay)
# async def create_community(...):
#      conn=get_db_connection(); cursor=conn.cursor()
#      try:
#          # db_location_str = utils.format_location_for_db(community_data.primary_location)
#          community_id = crud.create_community_db(cursor, ..., created_by=current_user_id, ...)
#          # fetch created community details for response
#          # ... handle errors ... commit ... return ...
#      finally: conn.close()

# @router.get("", response_model=List[schemas.CommunityDisplay])
# async def get_communities(...):
#      # ... fetch using crud.get_communities_db ...
#      # ... process location point string ... return ...

# ... other community routes ...
