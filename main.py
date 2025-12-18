from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from src.routers import router
from src.models import init_model
import logging
from src.utils.ultravoxmanager import UltraVoxManager

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


model_manager = None
@asynccontextmanager
async def lifespan(app: FastAPI):
    init_model()  # Load once
    yield 
    logger.info("Shutdown")

    
app = FastAPI(lifespan=lifespan)

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

@app.get("/ping")
async def ping():
    logger.info("Ping received - worker healthy!")
    return {"ping": "pong"}


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    logger.info("Health check received!")
    return {
        "status": "healthy",
        "model": "fixie-ai/ultravox-v0_4",
        "service": "ready"
    }

