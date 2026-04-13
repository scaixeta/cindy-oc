"""Dual Model Gate — Semantic routing for 5-agent team"""
from typing import Literal

def route(message: str) -> Literal["MiniMax-M2.7", "GLM-5.1"]:
    patterns = {
        "GLM-5.1": ["analisar código", "implementar", "debugar", "arquitetura", "complexo"],
        "MiniMax-M2.7": ["operacional", "telegram", "coordenação", "simples", "rapidez"]
    }
    msg_lower = message.lower()
    for model, triggers in patterns.items():
        if any(t in msg_lower for t in triggers):
            return model
    return "MiniMax-M2.7"
