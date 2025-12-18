# pip install transformers peft librosa

from fastapi import File, UploadFile
import torch
from transformers import AutoModel
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
        pipe = AutoModel.from_pretrained("fixie-ai/ultravox-v0_7-glm-4_6", trust_remote_code=True, torch_dtype=torch.float16, device_map="auto"  )
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
        return self.pipe({'audio': audio, 'turns': turns, 'sampling_rate': sr}, max_new_tokens=30)


