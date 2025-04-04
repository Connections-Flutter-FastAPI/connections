# backend/routers/votes.py
from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Optional
import psycopg2

from .. import schemas, crud, auth
from ..database import get_db_connection

router = APIRouter(
    prefix="/votes",
    tags=["Votes"],
)

@router.post("", status_code=status.HTTP_200_OK) # Default 200 OK, response message indicates action
async def create_or_update_vote(
    vote_data: schemas.VoteCreate, # Validates one target is present
    current_user_id: int = Depends(auth.get_current_user)
):
    """Creates, updates, or deletes a vote based on user's action."""
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        post_id = vote_data.post_id
        reply_id = vote_data.reply_id
        vote_type = vote_data.vote_type
        target_type = "post" if post_id else "reply"
        target_id = post_id if post_id else reply_id

        existing_vote = crud.get_existing_vote(cursor, current_user_id, post_id, reply_id)

        if existing_vote:
            existing_vote_id = existing_vote['id']
            existing_vote_type = existing_vote['vote_type']

            if existing_vote_type == vote_type: # Clicked same button again - Undo
                crud.delete_vote_db(cursor, existing_vote_id)
                conn.commit()
                print(f"✅ Vote undone (deleted) for user {current_user_id} on {target_type} {target_id}")
                return {"message": "Vote removed"}
            else: # Clicked other button - Switch
                crud.update_vote_db(cursor, existing_vote_id, vote_type)
                conn.commit()
                print(f"✅ Vote switched for user {current_user_id} on {target_type} {target_id} to {vote_type}")
                # Optionally return updated vote counts here if needed
                return {"message": "Vote updated", "new_vote_type": vote_type}
        else: # No existing vote - Create new
            new_vote_id = crud.create_vote_db(cursor, current_user_id, post_id, reply_id, vote_type)
            conn.commit()
            if not new_vote_id:
                 raise HTTPException(status_code=500, detail="Vote insertion failed")
            print(f"✅ New vote recorded for user {current_user_id} on {target_type} {target_id}, type: {vote_type}")
            # Optionally return vote counts here if needed
            return {"message": "Vote recorded", "vote_id": new_vote_id, "vote_type": vote_type}

    except psycopg2.IntegrityError as e:
         if conn: conn.rollback()
         print(f"❌ Vote Integrity Error: {e}")
         # Could be FK violation if post/reply doesn't exist, or check constraint violation
         raise HTTPException(status_code=400, detail="Invalid vote target or combination.")
    except Exception as e:
        if conn: conn.rollback()
        print(f"❌ Vote error [{e.__class__.__name__}]: {e}")
        raise HTTPException(status_code=500, detail=f"An error occurred during voting: {str(e)}")
    finally:
        if conn: conn.close()

@router.get("", response_model=List[schemas.VoteDisplay]) # Keep if needed for debugging/listing
async def get_votes(post_id: Optional[int] = None, reply_id: Optional[int] = None):
    """Fetches votes for a specific post or reply."""
    if not post_id and not reply_id:
        raise HTTPException(status_code=400, detail="Either post_id or reply_id must be provided.")

    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        votes_db = crud.get_votes_db(cursor, post_id=post_id, reply_id=reply_id)
        print(f"✅ Fetched {len(votes_db)} votes for post={post_id}, reply={reply_id}")
        return votes_db
    except Exception as e:
        print(f"❌ Error fetching votes: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if conn: conn.close()
