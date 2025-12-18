from fastapi import APIRouter, File, Form, UploadFile
from src.models import get_model 
import logging
logger = logging.getLogger(__name__)


router = APIRouter(prefix='/api/v1')    
@router.post('/invoke')
async def chat(system_prompt : str = Form(...),
    audio_file: UploadFile = File(...)
    ) :
    model_manager= get_model()
    logger.info(f"Model Recieved to router {model_manager}")
    logger.info(f"Invoke: {system_prompt[:50]}...")
    return await model_manager.invoke_audio(system_prompt , audio_file.file)