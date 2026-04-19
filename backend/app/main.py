from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import thai_chat
from app.config import settings

app = FastAPI(
    title="AUDY Thai Chat Backend",
    description="Thai chat API for autistic children's learning app",
    version="1.0.0",
)

# CORS for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(thai_chat.router)


@app.get("/")
async def root():
    return {"message": "AUDY Thai Chat API", "version": "1.0.0"}