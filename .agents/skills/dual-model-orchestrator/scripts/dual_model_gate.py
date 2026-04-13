#!/usr/bin/env python3
"""
dual_model_gate.py — Gate semântico de roteamento para equipe de 5 agentes

Roteia tarefas entre: Cindy, Sentivis, MiniMax, Scribe, GLM-5.1
Zero LLM no caminho de roteamento — decisão por análise de palavras-chave.

Uso:
    python dual_model_gate.py "sua tarefa aqui"
    python dual_model_gate.py --prompt "sua tarefa aqui"
    echo "sua tarefa" | python dual_model_gate.py

Retorna:
    SENTIVIS — > IoT/Infra: ThingsBoard, n8n, Cirrus Lab, JWS
    MINIMAX  — > Código/AI: CindyAgent, DOC2.5, Hermes, OpenCode
    SCRIBE   — > Docs/API: Swagger, dashboards, documentação técnica
    GLM      — > Validação: code review, validação semântica, auditoria
    CINDY    — > Triagem/coordenação (fallback)
"""

import sys
import re


# Palavras que direcionam para Sentivis (IoT/Infra)
SENTIVIS_KEYWORDS = [
    "thingsboard", "tb", "iot", "sensor", "telemetria", "device", "dispositivo",
    "n8n", "webhook", "workflow", "automação", "automacao", "integration",
    "cirrus", "cirruslab", "nimbus", "atmos", "aerolab",
    "jws", "java web service", "rest api iot", "mqtt", "coap",
    "asset", "tenant", "dashboard iot", "rule chain", "telemetry",
    "alarme", "threshold", "widget", "time series", "tempo real",
]

# Palavras que direcionam para MiniMax (código/AI)
MINIMAX_KEYWORDS = [
    "codigo", "código", "python", "debug", "bug", "depurar",
    "cindyagent", "hermes", "opencode", "telegram", "gateway",
    "doc2.5", "governanca", "regras", "skills", "memory",
    "implementar", "feature", "função", "funcao", "classe",
    "gitlab", "github", "repo", "commit", "branch",
    "teste", "testar", "pytest", "unittest",
]

# Palavras que direcionam para Scribe (docs/API)
SCRIBE_KEYWORDS = [
    "swagger", "openapi", "api", "endpoint", "documentar", "docs",
    "readme", "manual", "guia", "tutorial", "referencia",
    "dashboard", "relatorio", "relatório", "visualização", "grafico", "gráfico",
    "contract", "contrato", "schema", "spec", "specification",
    "markdown", "md", "readme", "changelog", "versionar",
]

# Palavras que direcionam para GLM (validação)
GLM_KEYWORDS = [
    "validar", "validacao", "validação", "review", "code review", "auditar",
    "melhorar", "otimizar", "refatorar", "performance", "benchmark",
    "teste", "testar", "correção", "correcao", "corrigir", "fix",
    "matematica", "matemática", "logica", "lógica", "algoritmo",
    "regex", "parse", "parser", "sql", "query", "schema",
    "math", "calcul", "equation", "equa", "percentual", "taxa",
]

# Palavras que direcionam para Cindy (triagem/coordenação)
CINDY_KEYWORDS = [
    "coorden", "organiz", "triagem", "prioridade", "planejar", "planejamento",
    "roadmap", "sprint", "backlog", "tarefa", "task", "discussão", "debate",
    "decidir", "decisão", "estratégia", "estrategia", "abordagem",
]


def classify(prompt: str) -> str:
    """
    Classifica o prompt com base em palavras-chave.
    Retorna: SENTIVIS, MINIMAX, SCRIBE, GLM ou CINDY.
    Prioridade: Sentivis > Scribe > GLM > MiniMax > Cindy
    """
    prompt_lower = prompt.lower()
    prompt_normalized = re.sub(r'[^\w\s]', ' ', prompt_lower)

    scores = {
        "SENTIVIS": sum(1 for kw in SENTIVIS_KEYWORDS if kw in prompt_normalized),
        "SCRIBE": sum(1 for kw in SCRIBE_KEYWORDS if kw in prompt_normalized),
        "GLM": sum(1 for kw in GLM_KEYWORDS if kw in prompt_normalized),
        "MINIMAX": sum(1 for kw in MINIMAX_KEYWORDS if kw in prompt_normalized),
        "CINDY": sum(1 for kw in CINDY_KEYWORDS if kw in prompt_normalized),
    }

    # Retorna o maior score; se todos zero, retorna MINIMAX (fallback)
    winner = max(scores, key=scores.get)
    if scores[winner] == 0:
        return "MINIMAX"
    return winner


def main():
    # Lê do argumento ou de stdin
    if len(sys.argv) > 1 and sys.argv[1] != "--prompt":
        prompt = " ".join(sys.argv[1:])
    elif len(sys.argv) > 2 and sys.argv[1] == "--prompt":
        prompt = " ".join(sys.argv[2:])
    else:
        # Lê de stdin
        prompt = sys.stdin.read().strip()

    if not prompt:
        print("Uso: python dual_model_gate.py <prompt>")
        print("   ou: echo 'prompt' | python dual_model_gate.py")
        sys.exit(1)

    result = classify(prompt)
    print(result)


if __name__ == "__main__":
    main()
