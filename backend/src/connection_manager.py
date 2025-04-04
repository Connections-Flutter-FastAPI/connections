# backend/connection_manager.py
from typing import Dict, List, Set
from fastapi import WebSocket

class ConnectionManager:
    def __init__(self):
        # Structure: { "community_{id}": {websocket1, websocket2}, "event_{id}": {websocket3} }
        self.active_connections: Dict[str, Set[WebSocket]] = {}

    async def connect(self, websocket: WebSocket, room_id: str):
        await websocket.accept()
        if room_id not in self.active_connections:
            self.active_connections[room_id] = set()
        self.active_connections[room_id].add(websocket)
        print(f"WebSocket connected to room: {room_id}. Total in room: {len(self.active_connections[room_id])}")

    def disconnect(self, websocket: WebSocket, room_id: str):
        if room_id in self.active_connections:
            self.active_connections[room_id].remove(websocket)
            print(f"WebSocket disconnected from room: {room_id}. Remaining: {len(self.active_connections[room_id])}")
            if not self.active_connections[room_id]:
                del self.active_connections[room_id] # Clean up empty room

    async def broadcast(self, message: str, room_id: str):
        if room_id in self.active_connections:
            print(f"Broadcasting to room {room_id}: {message}")
            disconnected_websockets = set()
            for connection in self.active_connections[room_id]:
                try:
                    await connection.send_text(message)
                except Exception as e:
                    print(f"Error sending message to a websocket in room {room_id}: {e} - marking for disconnection")
                    disconnected_websockets.add(connection)

            # Remove disconnected sockets after iterating
            for ws in disconnected_websockets:
                 self.disconnect(ws, room_id)


# Instantiate a single manager for the application
manager = ConnectionManager()
