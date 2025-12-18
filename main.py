from contextlib import asynccontextmanager
from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware
import numpy as np
import torch
import logging
from src.utils.ultravoxmanager import AudioRingBuffer, UltraVoxManager

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


model_manager = None
@asynccontextmanager
async def lifespan(app: FastAPI):
    
    global model_manager
    if model_manager is None:
        logger.info("Global: Loading model ONCE in init_model()...")
        model_manager = UltraVoxManager()
        logger.info("Global: Model LOADED in init_model()")
    else:
        logger.info("Global: init_model() called but model already loaded")

    yield
    logger.info("Lifespan: shutdown")
    del model_manager

    
app = FastAPI(lifespan=lifespan)



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


# websocket streaming

@app.websocket("/ws")
async def ws(ws: WebSocket):
    logger.info("Connected with the websocket")
    await ws.accept()

    buffer = AudioRingBuffer(max_samples=int(0.5 * 16000))  # 500 ms
    SLIDE = int(0.15 * 16000)  # 150 ms
    MIN_WINDOW = int(0.3 * 16000)  # 300 ms

    try:
        while True:
            chunk = await ws.receive_bytes()
            logger.info("Reciewved bytes")

            audio = np.frombuffer(chunk, dtype=np.int16)
            audio = audio.astype(np.float32) / 32768.0

            buffer.add(audio)
            logger.info("Add audio to buffer")
            if len(buffer.buffer) >= MIN_WINDOW:
                window_audio = buffer.get()
                logger.info('invoke the audio to the model')
                text = model_manager.infer_window(window_audio)
                logger.info(f"Result recieved from ultravox {text}")
                if text.strip():
                    await ws.send_text(text)

                buffer.slide(SLIDE)

    except Exception as e :
        ws.close()
        raise ValueError(str(e))
    

