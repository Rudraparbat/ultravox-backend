from fastapi import File, HTTPException

from src.utils.ultravoxmanager import UltraVoxManager
import logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class UltraVoxServices :
    
    def __init__(self):
        self.manager =  UltraVoxManager()
        

    async def invoke_voice(self, system_prompt : str , audio : File) -> dict :
        try : 
            
            result = self.manager.invoke_audio(system_prompt , audio)
            logger.info(f"invoked and recieved result {result}")
            return {"response" : str(result)}
        except Exception as e :
            raise HTTPException(status_code= 400 , detail= str(e))