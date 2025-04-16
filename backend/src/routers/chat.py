# backend/routers/chat.py
from fastapi import APIRouter, Depends, HTTPException, status, Query
from typing import List, Optional
import psycopg2

from .. import schemas, crud, auth
from ..database import get_db_connection
from ..connection_manager import manager # Import manager to broadcast HTTP messages

router = APIRouter(
    prefix="/chat",
    tags=["Chat"],
)

@router.post("/messages", status_code=status.HTTP_201_CREATED, response_model=schemas.ChatMessageData)
async def send_chat_message_http(
    message_data: schemas.ChatMessageCreate,
    current_user_id: int = Depends(auth.get_current_user),
    community_id: Optional[int] = Query(None),
    event_id: Optional[int] = Query(None)
):
    """Sends a chat message via HTTP and broadcasts it via WebSocket."""
    if community_id is None and event_id is None:
        raise HTTPException(status_code=400, detail="Either community_id or event_id query parameter must be provided.")
    # Allowing both might be complex, stick to one for now or define priority
    if community_id is not None and event_id is not None:
         raise HTTPException(status_code=400, detail="Cannot specify both community_id and event_id.")

    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        # Create message in DB using CRUD
        created_message_data = crud.create_chat_message_db(
            cursor,
            user_id=current_user_id,
            content=message_data.content,
            community_id=community_id,
            event_id=event_id
        )
        if not created_message_data:
             raise HTTPException(status_code=500, detail="Message insertion failed.")

        conn.commit()
        print(f"✅ Message {created_message_data['message_id']} saved to DB via HTTP.")

        # Prepare ChatMessageData object for broadcast and response
        chat_message_obj = schemas.ChatMessageData(**created_message_data)

        # Broadcast via WebSocket manager
        room_type = "community" if community_id else "event"
        room_id = community_id if community_id else event_id
        room_identifier = f"{room_type}_{room_id}"

        # Use .model_dump_json() for Pydantic v2 or .json() for v1
        # broadcast_message = chat_message_obj.model_dump_json() # Pydantic v2
        broadcast_message = chat_message_obj.json() # Pydantic v1

        await manager.broadcast(broadcast_message, room_identifier)
        print(f"📢 Broadcasted message to room {room_identifier}")

        return chat_message_obj # Return the created message data

    except psycopg2.Error as e:
        if conn: conn.rollback()
        print(f"❌ DB Error sending HTTP message: {e}")
        raise HTTPException(status_code=500, detail=f"Database error: {e.pgerror}")
    except Exception as e:
        if conn: conn.rollback()
        print(f"❌ Error sending message via HTTP: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if conn: conn.close()


@router.get("/messages", response_model=List[schemas.ChatMessageData])
async def get_chat_messages(
    community_id: Optional[int] = Query(None),
    event_id: Optional[int] = Query(None),
    limit: int = Query(50, gt=0, le=200), # Add validation
    before_id: Optional[int] = Query(None) # For pagination
):
    """Fetches historical chat messages for a community or event."""
    if community_id is None and event_id is None:
        raise HTTPException(status_code=400, detail="Either community_id or event_id query parameter must be provided.")

    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        messages_db = crud.get_chat_messages_db(
            cursor,
            community_id=community_id,
            event_id=event_id,
            limit=limit,
            before_id=before_id
        )

        # Convert raw db dictionaries to ChatMessageData objects
        # Pydantic will handle the validation
        messages = [schemas.ChatMessageData(**msg) for msg in messages_db]

        print(f"✅ Fetched {len(messages)} messages via HTTP (Comm={community_id}, Event={event_id})")
        # Return newest first (as fetched by query), frontend should reverse if needed
        return messages
    except Exception as e:
        print(f"❌ Error fetching HTTP messages: {e}")
        raise HTTPException(status_code=500, detail="Error fetching messages")
    finally:
        if conn: conn.close()
