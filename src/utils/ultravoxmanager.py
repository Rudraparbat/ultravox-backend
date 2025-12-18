# pip install transformers peft librosa

from fastapi import File, UploadFile
import torch
import transformers 
import numpy as np
import librosa
import logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class UltraVoxManager :

    def __init__(self):
        self.pipe = self.__load_model()

    def __load_model(self) :
        # load the model here
        logger.info("Loading Ultravox model...")
        if not torch.cuda.is_available():
            # check for gpu
            raise RuntimeError("No GPU found!")
        
        pipe = transformers.pipeline(model='fixie-ai/ultravox-v0_4', trust_remote_code=True , device_map="auto")
        logger.info("Loaded Model Done")
        logger.info(f"Pipeline loaded on GPU: {pipe.device}")
        logger.info("Loaded Model Done")
        return pipe


    def invoke_audio(self , prompt : str , audio_file : File) :

        # invoke the input for result
        audio, sr = librosa.load(audio_file, sr=16000)

        turns = [
        {
            "role": "system",
            "content": str(prompt)
        },
        ]
        logger.info('Invoking the audio')
        result =  self.pipe({'audio': audio, 'turns': turns, 'sampling_rate': sr}, max_new_tokens=30)
        logger.info(f"invoked and recieved result {result}")
        return {"response" : str(result)}
