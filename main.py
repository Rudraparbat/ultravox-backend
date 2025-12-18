from contextlib import asynccontextmanager
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
import numpy as np
import logging
from src.utils.ultravoxmanager import AudioRingBuffer, UltraVoxManager
from src.utils.vadmanager import VAD

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

    buffer = AudioRingBuffer(max_samples=int(0.5 * 16000))  
    SLIDE = int(0.15 * 16000)  
    MIN_WINDOW = int(0.3 * 16000) 
    vad = VAD()
    speech_active = False
    silence_ms = 0
    last_text = ""

    try:
        while True:
            chunk = await ws.receive_bytes()
            logger.info("Reciewved bytes")

            audio = np.frombuffer(chunk, dtype=np.int16)
            audio = audio.astype(np.float32) / 32768.0

            buffer.add(audio)
            if len(buffer.buffer) < MIN_WINDOW:
                continue

            window_audio = buffer.get()

            has_speech = vad.is_speech(window_audio)

            if not has_speech:
                if speech_active:
                    silence_ms += int(len(window_audio) / 16000 * 1000)

                    if silence_ms >= 400:
    
                        final_text = model_manager.finalize()
                        if final_text.strip():
                            await ws.send_text(final_text)

                        # reset state
                        buffer.reset()
                        model_manager.reset()
                        speech_active = False
                        silence_ms = 0
                        last_text = ""
                continue

    
            speech_active = True
            silence_ms = 0

            text = model_manager.infer_window(window_audio)

            if text and text != last_text:
                await ws.send_text(text)
                last_text = text

            buffer.slide(SLIDE)

    except WebSocketDisconnect:
        logger.info("Client disconnected")

    except Exception as e:
        logger.error(f"WS error: {e}")
        await ws.close()