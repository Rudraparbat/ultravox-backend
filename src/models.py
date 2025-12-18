import logging
from src.utils.ultravoxmanager import UltraVoxManager

logger = logging.getLogger(__name__)
model_manager = None

def init_model():
    global model_manager
    logger.info("Global: Loading model ONCE...")
    model_manager = UltraVoxManager()
    logger.info("Global model LOADED!")

def get_model():
    return model_manager
