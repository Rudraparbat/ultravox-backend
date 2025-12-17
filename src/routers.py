from fastapi import APIRouter, File, UploadFile

from src.services import UltraVoxServices


router = APIRouter(prefix='/api/v1')
service = UltraVoxServices()

@router.post('/invoke')
async def chat(system_prompt : str ,
    audio_file: UploadFile = File(...)
    ) :
    return await service.invoke_voice(system_prompt , audio_file.file)