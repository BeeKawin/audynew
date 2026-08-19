"""Debug broadcast relay.

A bare WebSocket fan-out: any connected client (the debug page, or any
running AUDY app instance) sends a small JSON event and every *other*
connected client receives it immediately. There is no pairing, auth, or
persistence — this exists purely so a developer/tester can trigger a fake
robot touch or emotion-mimic result on one device from another, for testing
without the physical BLE hardware or camera.

Message shape (JSON, sender -> relay -> all other clients, unchanged):
  {"type": "touch", "channel": "ears", "value": 1}
  {"type": "mimic_result", "correct": true}
"""

import json
import logging

from fastapi import APIRouter, WebSocket, WebSocketDisconnect

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/ws", tags=["debug"])


class BroadcastManager:
    def __init__(self) -> None:
        self._connections: list[WebSocket] = []

    async def connect(self, websocket: WebSocket) -> None:
        await websocket.accept()
        self._connections.append(websocket)

    def disconnect(self, websocket: WebSocket) -> None:
        if websocket in self._connections:
            self._connections.remove(websocket)

    async def broadcast(self, message: str, sender: WebSocket) -> None:
        stale: list[WebSocket] = []
        for connection in self._connections:
            if connection is sender:
                continue
            try:
                await connection.send_text(message)
            except Exception:
                stale.append(connection)
        for connection in stale:
            self.disconnect(connection)


manager = BroadcastManager()


@router.websocket("/debug-broadcast")
async def debug_broadcast(websocket: WebSocket) -> None:
    await manager.connect(websocket)
    try:
        while True:
            raw = await websocket.receive_text()
            try:
                json.loads(raw)
            except ValueError:
                logger.warning("debug_broadcast: dropping non-JSON message: %s", raw)
                continue
            await manager.broadcast(raw, sender=websocket)
    except WebSocketDisconnect:
        manager.disconnect(websocket)
