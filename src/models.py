import logging
from src.utils.ultravoxmanager import UltraVoxManager

logger = logging.getLogger(__name__)
model_manager = None

def init_model():
    global model_manager
    if model_manager is None:
        logger.info("Global: Loading model ONCE in init_model()...")
        model_manager = UltraVoxManager()
        logger.info("Global: Model LOADED in init_model()")
    else:
        logger.info("Global: init_model() called but model already loaded")

def get_model():
    if model_manager is None:
        logger.error("Global: get_model() called BEFORE init_model()!")
        raise RuntimeError("Model not initialized")
    logger.info("Global: get_model() returning existing model")
    return model_manager
