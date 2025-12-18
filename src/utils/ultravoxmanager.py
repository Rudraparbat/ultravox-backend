from transformers import AutoModel, AutoProcessor
import torch
import collections
import numpy as np

class UltraVoxManager:
    def __init__(self):
        self.processor = AutoProcessor.from_pretrained(
            "fixie-ai/ultravox-v0_4",
            trust_remote_code=True
        )

        self.model = AutoModel.from_pretrained(
            "fixie-ai/ultravox-v0_4",
            trust_remote_code=True,
            device_map="auto",
            torch_dtype=torch.float16
        )

        self.model.eval()

    def reset(self):
        self.stream_state = None  # or recreate stream

    def finalize(self):
        if self.stream_state:
            return self.model.finalize(self.stream_state)
        return ""
    
    def infer_window(self, audio_np):
        inputs = self.processor(
            audio=audio_np,
            sampling_rate=16000,
            return_tensors="pt"
        ).to("cuda")

        with torch.inference_mode():
            out = self.model.generate(
                **inputs,
                max_new_tokens=30
            )

        return self.processor.decode(out[0], skip_special_tokens=True)
    


class AudioRingBuffer:
    def __init__(self, max_samples):
        self.buffer = collections.deque(maxlen=max_samples)

    def add(self, samples):
        self.buffer.extend(samples)

    def get(self):
        return np.array(self.buffer, dtype=np.float32)

    def slide(self, samples):
        for _ in range(samples):
            if self.buffer:
                self.buffer.popleft()
