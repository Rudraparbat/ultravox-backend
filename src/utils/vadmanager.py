import torch
import numpy as np
from silero_vad import load_silero_vad, get_speech_timestamps

class VAD:
    def __init__(self, sr=16000, threshold=0.5):
        self.model = load_silero_vad()
        self.sr = sr
        self.threshold = threshold

    def is_speech(self, audio: np.ndarray) -> bool:
        if len(audio) < int(0.1 * self.sr):  # <100 ms → ignore
            return False

        audio = torch.from_numpy(audio).float()
        timestamps = get_speech_timestamps(
            audio,
            self.model,
            sampling_rate=self.sr,
            threshold=self.threshold,
            min_speech_duration_ms=80,
            min_silence_duration_ms=100
        )
        return len(timestamps) > 0
