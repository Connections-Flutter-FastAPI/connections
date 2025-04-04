# backend/routers/events.py
from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Optional
import psycopg2

from .. import schemas, crud, auth
from ..database import get_db_connection

router = APIRouter(
    prefix="/events",
    tags=["Events"],
)

@router.get("/{event_id}", response_model=schemas.EventDisplay)
async def get_event_details(event_id: int):
    """Fetches details for a specific event."""
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        event_db = crud.get_event_details_db(cursor, event_id)
        if not event_db:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Event not found")
        print(f"✅ Fetched details for event {event_id}")
        # Pydantic handles validation
        return event_db
    except Exception as e:
        print(f"❌ Error fetching event details {event_id}: {e}")
        raise HTTPException(status_code=500, detail="Error fetching event details")
    finally:
        if conn: conn.close()


@router.put("/{event_id}", response_model=schemas.EventDisplay)
async def update_event(
    event_id: int,
    event_update: schemas.EventUpdate,
    current_user_id: int = Depends(auth.get_current_user)
):
    """Updates an event (only creator can update)."""
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Check ownership
        event = crud.get_event_details_db(cursor, event_id) # Fetch first
        if not event:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Event not found")
        if event['creator_id'] != current_user_id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to update this event")

        update_data = event_update.dict(exclude_unset=True) # Get only provided fields
        if not update_data:
            raise HTTPException(status_code=400, detail="No update data provided")

        updated_event_db = crud.update_event_db(cursor, event_id, update_data)
        if not updated_event_db:
             # This might happen if RETURNING * failed or update affected 0 rows unexpectedly
             raise HTTPException(status_code=500, detail="Event update failed")

         # Fetch participant count separately after update
        participant_count = crud.get_event_participant_count(cursor, event_id)
        conn.commit()
        print(f"✅ Event {event_id} updated successfully by User {current_user_id}")

        # Add participant count to the response dict before validation
        updated_event_db['participant_count'] = participant_count
        return schemas.EventDisplay(**updated_event_db)

    except HTTPException as http_exc:
         if conn: conn.rollback()
         raise http_exc
    except psycopg2.Error as e:
        if conn: conn.rollback()
        print(f"❌ DB Error updating event {event_id}: {e}")
        raise HTTPException(status_code=500, detail=f"Database error: {e.pgerror}")
    except Exception as e:
        if conn: conn.rollback()
        print(f"❌ Error updating event {event_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if conn: conn.close()

@router.delete("/{event_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_event(
    event_id: int,
    current_user_id: int = Depends(auth.get_current_user)
):
    """Deletes an event (only creator can delete)."""
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        # Check ownership
        event = crud.get_event_details_db(cursor, event_id)
        if not event:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Event not found")
        if event['creator_id'] != current_user_id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to delete this event")

        rows_deleted = crud.delete_event_db(cursor, event_id)
        conn.commit()

        if rows_deleted == 0:
             print(f"⚠️ Event {event_id} not found during delete.")
             raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Event not found")

        print(f"✅ Event {event_id} deleted successfully by User {current_user_id}")
        return None
    except HTTPException as http_exc:
         if conn: conn.rollback()
         raise http_exc
    except Exception as e:
        if conn: conn.rollback()
        print(f"❌ Error deleting event {event_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if conn: conn.close()


@router.post("/{event_id}/join", status_code=status.HTTP_200_OK)
async def join_event(
    event_id: int,
    current_user_id: int = Depends(auth.get_current_user)
):
    """Allows the current user to join an event."""
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        # Check if event is full BEFORE attempting insert
        event_details = crud.get_event_details_db(cursor, event_id)
        if not event_details:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Event not found")
        if event_details['participant_count'] >= event_details['max_participants']:
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Event is full")

        participant_id = crud.join_event_db(cursor, event_id, current_user_id)
        conn.commit()
        if participant_id:
            return {"message": "Successfully joined event"}
        else:
            return {"message": "Already joined this event"}
    except psycopg2.Error as e:
        if conn: conn.rollback()
        if e.pgcode == '23503': # FK violation
             raise HTTPException(status_code=404, detail="Event not found")
        raise HTTPException(status_code=500, detail=f"Database error: {e.pgerror}")
    except HTTPException as http_exc: # Catch specific 409/404 from checks
        if conn: conn.rollback()
        raise http_exc
    except Exception as e:
        if conn: conn.rollback()
        print(f"❌ Error joining event {event_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if conn: conn.close()


@router.delete("/{event_id}/leave", status_code=status.HTTP_200_OK)
async def leave_event(
    event_id: int,
    current_user_id: int = Depends(auth.get_current_user)
):
    """Allows the current user to leave an event."""
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        deleted_id = crud.leave_event_db(cursor, event_id, current_user_id)
        conn.commit()
        if deleted_id:
            return {"message": "Successfully left event"}
        else:
            return {"message": "Not currently participating in this event"}
    except Exception as e:
        if conn: conn.rollback()
        print(f"❌ Error leaving event {event_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if conn: conn.close()
