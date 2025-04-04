# backend/routers/websocket.py
import json
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends, status, Query
from typing import Optional
import psycopg2

from .. import schemas, crud, auth # Need auth for potential token validation
from ..database import get_db_connection
from ..connection_manager import manager

router = APIRouter(tags=["WebSocket"])

# --- Helper function for WebSocket Authentication (Example: Token in Query) ---
async def get_current_user_ws(
    websocket: WebSocket,
    token: Optional[str] = Query(None) # Get token from query param ?token=...
) -> Optional[int]:
    if token is None:
        print("WS Auth: No token provided.")
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION, reason="Missing token")
        return None
    try:
        # Reuse the synchronous logic from auth.py, adapting slightly if needed
        # NOTE: This blocks the async event loop briefly. For high-load, use async JWT libraries.
        payload = jwt.decode(token, auth.SECRET_KEY, algorithms=[auth.ALGORITHM])
        user_id = int(payload.get("user_id"))
        print(f"WS Auth: User {user_id} authenticated.")
        # Optionally update last_seen here too, but might add latency
        # update_last_seen(user_id) # Be cautious with DB calls in WS auth
        return user_id
    except Exception as e:
        print(f"WS Auth Error: {e}")
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION, reason=f"Authentication failed: {e}")
        return None
# --- End Helper ---


@router.websocket("/ws/{room_type}/{room_id}")
async def websocket_endpoint(
    websocket: WebSocket,
    room_type: str,
    room_id: int,
    token: Optional[str] = Query(None) # Accept token via query parameter
):
    """Handles WebSocket connections for chat rooms (community or event)."""

    # --- Basic Authentication ---
    # user_id = await get_current_user_ws(websocket, token=token) # Use helper
    # For now, skip strict WS auth to match previous behaviour, but add TODO
    # TODO: Implement robust WebSocket authentication (e.g., using token query param or initial message)
    user_id = 1 # Placeholder if auth is skipped - REPLACE THIS

    valid_room_types = ["community", "event"]
    if room_type not in valid_room_types:
        print(f"Invalid room type: {room_type}")
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION, reason="Invalid room type")
        return

    room_identifier = f"{room_type}_{room_id}"

    await manager.connect(websocket, room_identifier)
    print(f"WebSocket connected for room: {room_identifier}") # Log successful connection

    try:
        while True:
            data = await websocket.receive_text()
            print(f"WS Received in {room_identifier}: {data}")

            # --- Process incoming message ---
            try:
                message_data = json.loads(data)
                content = message_data.get('content')

                if not content:
                    print("WS Warning: Received message without content.")
                    # Optionally send an error back to the client
                    # await websocket.send_text(json.dumps({"error": "Message content is missing"}))
                    continue

                # --- Save message to DB ---
                conn = None
                try:
                    conn = get_db_connection()
                    cursor = conn.cursor()
                    # Determine community/event ID based on room_type
                    msg_community_id = room_id if room_type == "community" else None
                    msg_event_id = room_id if room_type == "event" else None

                    created_message = crud.create_chat_message_db(
                        cursor,
                        user_id=user_id, # Use authenticated user ID
                        content=content,
                        community_id=msg_community_id,
                        event_id=msg_event_id
                    )
                    conn.commit()

                    if created_message:
                        # Prepare Pydantic model for broadcasting
                        broadcast_obj = schemas.ChatMessageData(**created_message)
                        # broadcast_json = broadcast_obj.model_dump_json() # Pydantic v2
                        broadcast_json = broadcast_obj.json() # Pydantic v1
                        await manager.broadcast(broadcast_json, room_identifier)
                        print(f"📢 WS Broadcasted: {broadcast_json}")
                    else:
                        print("WS Error: Failed to save message to DB.")
                        # Notify sender?

                except Exception as db_error:
                     if conn: conn.rollback()
                     print(f"WS DB Error processing message: {db_error}")
                     # Notify sender?
                finally:
                     if conn: conn.close()
                # --- End DB interaction ---

            except json.JSONDecodeError:
                print("WS Error: Received invalid JSON.")
                # Notify sender?
            except Exception as e:
                 print(f"WS Error processing received data: {e}")
                 # Notify sender?

    except WebSocketDisconnect as ws_exc:
        print(f"WebSocket disconnected from {room_identifier}: Code {ws_exc.code}, Reason: {ws_exc.reason}")
        manager.disconnect(websocket, room_identifier)
    except Exception as e:
         print(f"Error in WebSocket handler for {room_identifier}: {e}")
         manager.disconnect(websocket, room_identifier) # Ensure cleanup on unexpected error
         # Optionally try to close gracefully if possible
         try:
             await websocket.close(code=status.WS_1011_INTERNAL_ERROR)
         except:
             pass # Ignore errors during close after another error
    finally:
        # Final cleanup check
        manager.disconnect(websocket, room_identifier) # Call again to be safe
        print(f"Cleaned up connection for {room_identifier}")
