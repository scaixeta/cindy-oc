#!/usr/bin/env python3
"""
test_acp_multi_agent.py — Teste de comunicação ACP entre 2 agentes simulados

Simula: Sentivis (IoT) e MiniMax (AI) trocando mensagens via Redis ACP.
Agentes se comunicam em JSON estruturado (não linguagem humana).
Cindy observa e não se intromete a menos que necessário.
"""

import json
import uuid
import time
import threading
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from acp_redis import ACPRedis


# ─── Agente Simulado: Sentivis ──────────────────────────────────

def agent_sentivis():
    """Sentivis: IoT/Infra specialist. Recebe tarefas, processa, responde."""
    acp = ACPRedis()
    agent_id = "sentivis"
    
    print(f"[{agent_id}] Iniciando...")
    
    received_tasks = []
    
    def callback(msg):
        if msg.get("to") == agent_id or msg.get("to") == "*":
            print(f"[{agent_id}] RECEIVED: {msg['type']} from {msg['from']} | action={msg['action']}")
            print(f"           payload={json.dumps(msg['payload'], indent=2)}")
            
            if msg["type"] == "TASK":
                received_tasks.append(msg)
                
                # Simula processamento
                response_id = str(uuid.uuid4())
                
                # Responde para o originator
                acp.publish(
                    to=msg["from"],
                    msg_type="RESPONSE",
                    action="task_completed",
                    payload={
                        "original_task_id": msg["id"],
                        "response_id": response_id,
                        "result": f"Tarefa '{msg['action']}' executada por Sentivis",
                        "data": {"status": "ok", "processed": True}
                    },
                    from_agent=agent_id
                )
                print(f"[{agent_id}] RESPONDI to {msg['from']}: task_completed")
    
    # Subscreve no canal
    acp.subscribe(callback, agent_id=agent_id)


# ─── Agente Simulado: MiniMax ──────────────────────────────────

def agent_minimax():
    """MiniMax: AI/Code specialist. Envia tarefas para Sentivis e recebe respostas."""
    acp = ACPRedis()
    agent_id = "minimax"
    
    print(f"\n[{agent_id}] Iniciando...")
    
    # Espera um pouco para Sentivis estar pronto
    time.sleep(0.5)
    
    # Envia tarefa para Sentivis
    task_id = str(uuid.uuid4())
    print(f"[{agent_id}] ENVIANDO tarefa para sentivis...")
    
    acp.publish(
        to="sentivis",
        msg_type="TASK",
        action="configure_thresholds",
        payload={
            "task_id": task_id,
            "devices": ["NIMBUS-AERO", "ATMOS-WIND", "ATMOS-LINK"],
            "thresholds": {"temperature": 30, "humidity": 80, "pressure": 1013}
        },
        from_agent=agent_id
    )
    
    print(f"[{agent_id}] Tarefa enviada. Aguardando resposta...")
    
    # Aguarda resposta no stream
    time.sleep(2)
    
    # Consome do stream do minimax (respostas vindas de outros agentes)
    messages = acp.stream_consume(agent_id="minimax", group="test-group", consumer="minimax-consumer")
    
    print(f"\n[{agent_id}] Consumiu {len(messages)} mensagem(ns) do stream:minimax")
    for msg in messages:
        print(f"  from={msg['from']}, action={msg['action']}, payload={msg['payload']}")


# ─── Agente Simulado: Scribe (pub Broadcast) ───────────────────

def agent_scribe_broadcast():
    """Scribe: faz broadcast de evento para todos."""
    acp = ACPRedis()
    agent_id = "scribe"
    
    print(f"\n[{agent_id}] Broadcast de evento...")
    
    acp.publish(
        to="*",
        msg_type="EVENT",
        action="docs_updated",
        payload={
            "doc_id": "API-CONTRACT-001",
            "version": "1.2",
            "changed_by": "scribe"
        },
        from_agent=agent_id
    )
    print(f"[{agent_id}] Broadcast enviado.")


# ─── Teste: Ciclo completo entre 3 agentes ────────────────────

def test_multi_agent_cycle():
    """Teste: 3 agentes se comunicando via ACP sem falar comigo."""
    print("\n" + "=" * 60)
    print("TESTE: Comunicação Multi-Agente via ACP/Redis")
    print("=" * 60)
    
    acp = ACPRedis()
    
    # 1. Scribe faz broadcast de evento (não é para ninguém específico)
    print("\n[1] Scribe faz broadcast...")
    acp.publish(
        to="*",
        msg_type="EVENT",
        action="workflow_started",
        payload={"workflow_id": "WF-001", "steps": 3},
        from_agent="scribe"
    )
    print("[1] Broadcast enviado.")
    
    # 2. Cindy delega tarefa para Sentivis
    print("\n[2] Cindy delega tarefa para Sentivis...")
    task_id = str(uuid.uuid4())
    acp.publish(
        to="sentivis",
        msg_type="TASK",
        action="check_device_status",
        payload={
            "task_id": task_id,
            "device": "NIMBUS-ECHO-R1",
            "check": ["online", "telemetry", "alarms"]
        },
        from_agent="cindy"
    )
    print(f"[2] Tarefa enviada para Sentivis (task_id={task_id[:8]}...)")
    
    # 3. MiniMax também envia tarefa para Sentivis
    print("\n[3] MiniMax envia tarefa para Sentivis...")
    acp.publish(
        to="sentivis",
        msg_type="TASK",
        action="fetch_telemetry",
        payload={
            "task_id": str(uuid.uuid4()),
            "device": "ATMOS-LINK",
            "metrics": ["temperature", "humidity"],
            "time_range": "last_1h"
        },
        from_agent="minimax"
    )
    print("[3] Tarefa enviada.")
    
    # 4. GLM envia comando para MiniMax via stream
    print("\n[4] GLM envia comando para MiniMax via stream...")
    acp.stream_produce(
        agent_id="minimax",
        msg_type="COMMAND",
        action="review_code",
        payload={
            "file": "thingsboard_connector.py",
            "focus": "error_handling"
        },
        from_agent="glm"
    )
    print("[4] Comando enviado via stream.")
    
    # 5. Consome tudo do stream do minimax
    print("\n[5] Verificando stream:minimax...")
    time.sleep(0.5)
    msgs = acp.stream_consume(agent_id="minimax", group="test-group", consumer="minimax-consumer")
    print(f"[5] {len(msgs)} mensagem(ns) consumida(s) do stream")
    for msg in msgs:
        print(f"    -> {msg['from']} | {msg['action']} | {msg['payload']}")
    
    # 6. Verificar que mensagens ficaram registradas no Redis
    print("\n[6] Keys acp:* no Redis...")
    import redis
    r = redis.Redis(host='localhost', port=6379, decode_responses=True)
    keys = r.keys("acp:*")
    print(f"[6] {len(keys)} chave(s) encontrada(s):")
    for k in keys:
        k_str = k.decode() if isinstance(k, bytes) else k
        print(f"    - {k_str}")
    
    print("\n" + "=" * 60)
    print("TESTE CONCLUÍDO — Agentes se comunicaram sem linguagem humana")
    print("=" * 60)


if __name__ == "__main__":
    test_multi_agent_cycle()