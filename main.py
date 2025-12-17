from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from src.routers import router
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()

ALLOWED_ORIGINS = [
    "http://localhost",
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "*",
]

app.add_middleware(
    CORSMiddleware,
    allow_headers=["*"],
    allow_methods=["*"],
    allow_credentials=True,
    allow_origins=ALLOWED_ORIGINS
)

app.include_router(
    router ,
    prefix="/ultravox",
    tags=['Ultravox']
)

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "model": "ultravox-v0_7-glm-4_6",
        "service": "ready"
    }

@app.get("/")
async def root():
    """API Documentation"""
    return {
        "message": "Ultravox v0.7 API",
        "endpoints": ["/api/v1/invoke", "/health"],
        "docs": "/docs"
    }