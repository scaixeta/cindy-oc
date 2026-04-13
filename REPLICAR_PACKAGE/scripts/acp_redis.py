#!/usr/bin/env python3
"""
acp_redis.py — ACP (Agent Communication Protocol) via Redis

Fornece interface para comunicação entre agentes via Redis.
Uso: from acp_redis import ACPRedis

Formato de mensagem ACP:
{
    "id": "uuid-v4",
    "type": "TASK|COMMAND|EVENT|RESPONSE",
    "from": "agent_id",
    "to": "agent_id|*",
    "action": "mcp_delegate_task|code_review|doc_generate",
    "payload": {...},
    "meta": {
        "reply_to": "correlation_id",
        "timestamp": "ISO8601",
        "ttl_seconds": 300
    }
}
"""

import json
import uuid
import time
import threading
from datetime import datetime, timezone
from typing import Callable, Optional, Any


class ACPRedis:
    """
    Interface ACP via Redis.
    
    Canais:
    - acp:messages (Pub/Sub) — eventos efêmeros
    - acp:stream:{agent_id} (Streams) — tarefas persistidas
    """

    def __init__(self, channel: str = "acp:messages", stream_prefix: str = "acp:stream"):
        self.pubsub_channel = channel
        self.stream_prefix = stream_prefix
        self._p = None
        self._sub = None
        self._running = False

    # ─── Pub/Sub ────────────────────────────────────────────────

    def publish(self, to: str, msg_type: str, action: str, payload: dict, from_agent: str = "system") -> str:
        """Publica mensagem no canal Pub/Sub. Retorna message_id."""
        msg_id = str(uuid.uuid4())
        msg = {
            "id": msg_id,
            "type": msg_type,
            "from": from_agent,
            "to": to,
            "action": action,
            "payload": payload,
            "meta": {
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "reply_to": None
            }
        }
        import redis
        r = redis.Redis(host='localhost', port=6379, decode_responses=True)
        r.publish(self.pubsub_channel, json.dumps(msg))
        return msg_id

    def subscribe(self, callback: Callable[[dict], None], agent_id: str = "*"):
        """Subscreve no canal Pub/Sub. Callback recebe dict decodificado."""
        import redis
        r = redis.Redis(host='localhost', port=6379, decode_responses=True)
        p = r.pubsub()
        p.subscribe(self.pubsub_channel)
        self._running = True
        self._sub = p
        for message in p.listen():
            if not self._running:
                break
            if message['type'] == 'message':
                try:
                    data = json.loads(message['data'])
                    # Filtra por destino se especificado
                    if agent_id == "*" or data.get('to') == agent_id or data.get('to') == "*":
                        callback(data)
                except json.JSONDecodeError:
                    pass

    def stop_subscribe(self):
        """Para a subscrição."""
        self._running = False
        if self._sub:
            self._sub.close()

    # ─── Streams ────────────────────────────────────────────────

    def stream_produce(self, agent_id: str, msg_type: str, action: str, payload: dict, from_agent: str = "system") -> str:
        """Adiciona mensagem ao stream do agente. Retorna entry_id."""
        import redis
        r = redis.Redis(host='localhost', port=6379, decode_responses=True)
        stream_key = f"{self.stream_prefix}:{agent_id}"
        msg_id = str(uuid.uuid4())
        entry = {
            "id": msg_id,
            "type": msg_type,
            "from": from_agent,
            "action": action,
            "payload": json.dumps(payload),
            "meta": json.dumps({
                "timestamp": datetime.now(timezone.utc).isoformat()
            })
        }
        r.xadd(stream_key, entry, maxlen=1000)  # TTL: max 1000 entries
        return msg_id

    def stream_consume(self, agent_id: str, group: str = "agents", consumer: str = "consumer1", count: int = 10) -> list:
        """Consome mensagens do stream via consumer group. Retorna lista de mensagens."""
        import redis
        r = redis.Redis(host='localhost', port=6379, decode_responses=True)
        stream_key = f"{self.stream_prefix}:{agent_id}"
        
        try:
            r.xgroup_create(stream_key, group, id="0", mkstream=True)
        except redis.ResponseError:
            pass  # Group já existe
        
        messages = r.xreadgroup(group, consumer, {stream_key: ">"}, count=count)
        
        result = []
        for stream, entries in messages:
            for entry_id, fields in entries:
                msg = {
                    "entry_id": entry_id.decode() if isinstance(entry_id, bytes) else entry_id,
                    "id": fields.get(b"id", fields.get("id", "")).decode() if isinstance(fields.get(b"id", fields.get("id", "")), bytes) else fields.get(b"id", fields.get("id", "")),
                    "type": fields.get(b"type", fields.get("type", "")).decode() if isinstance(fields.get(b"type", fields.get("type", "")), bytes) else fields.get(b"type", fields.get("type", "")),
                    "from": fields.get(b"from", fields.get("from", "")).decode() if isinstance(fields.get(b"from", fields.get("from", "")), bytes) else fields.get(b"from", fields.get("from", "")),
                    "action": fields.get(b"action", fields.get("action", "")).decode() if isinstance(fields.get(b"action", fields.get("action", "")), bytes) else fields.get(b"action", fields.get("action", "")),
                    "payload": json.loads(fields.get(b"payload", fields.get("payload", "{}")).decode() if isinstance(fields.get(b"payload", fields.get("payload", "{}")), bytes) else fields.get(b"payload", fields.get("payload", "{}"))),
                    "meta": json.loads(fields.get(b"meta", fields.get("meta", "{}")).decode() if isinstance(fields.get(b"meta", fields.get("meta", "{}")), bytes) else fields.get(b"meta", fields.get("meta", "{}")))
                }
                result.append(msg)
                r.xack(stream_key, group, entry_id)
        return result

    def stream_pending(self, agent_id: str, group: str = "agents") -> list:
        """Lista mensagens pendentes no stream."""
        import redis
        r = redis.Redis(host='localhost', port=6379, decode_responses=True)
        stream_key = f"{self.stream_prefix}:{agent_id}"
        try:
            return r.xpending(stream_key, group)
        except redis.ResponseError:
            return []


def test_pubsub():
    """Teste básico Pub/Sub entre dois agents simulados."""
    import redis
    
    print("=== TESTE 1: Pub/Sub ===")
    acp = ACPRedis()
    
    # Teste publish
    msg_id = acp.publish(
        to="sentivis",
        msg_type="TASK",
        action="monitor_telemetry",
        payload={"device": "NIMBUS-AERO", "metric": "temperature"},
        from_agent="cindy"
    )
    print(f"Published: {msg_id}")
    
    # Verificar se chegou via redis-cli
    r = redis.Redis(host='localhost', port=6379, decode_responses=True)
    # Check last N messages in the channel
    print("Verificando Redis...")
    
    return msg_id


def test_stream():
    """Teste Stream com consumer group."""
    import redis
    
    print("\n=== TESTE 2: Stream ===")
    acp = ACPRedis()
    
    # Produzir mensagem para stream do Sentivis
    msg_id = acp.stream_produce(
        agent_id="sentivis",
        msg_type="TASK",
        action="configure_threshold",
        payload={"device": "ATMOS-WIND", "threshold": 80},
        from_agent="cindy"
    )
    print(f"Produced to stream:sentivis — ID: {msg_id}")
    
    # Consumir do stream
    messages = acp.stream_consume("sentivis", group="test-group", consumer="test-consumer")
    print(f"Consumed: {len(messages)} message(s)")
    if messages:
        print(f"  Action: {messages[0]['action']}")
        print(f"  Payload: {messages[0]['payload']}")
    
    return msg_id


def test_full_cycle():
    """Teste completo: Cindy envia → Sentivis recebe → Scribe responde."""
    import redis
    
    print("\n=== TESTE 3: Ciclo Completo ===")
    acp = ACPRedis()
    
    # Cindy publica tarefa para Sentivis
    task_id = acp.publish(
        to="sentivis",
        msg_type="TASK",
        action="analyze_telemetry",
        payload={
            "task_id": "T-001",
            "description": "Analisar telemetria do NIMBUS-AERO",
            "context": "temperature > 30 threshold"
        },
        from_agent="cindy"
    )
    print(f"Cindy → Sentivis: TASK published (id={task_id})")
    
    # Scribe também publica evento
    event_id = acp.publish(
        to="*",
        msg_type="EVENT",
        action="dashboard_ready",
        payload={"dashboard_id": "D-001", "widgets": 3},
        from_agent="scribe"
    )
    print(f"Scribe → *: EVENT published (id={event_id})")
    
    # Verificar streams
    r = redis.Redis(host='localhost', port=6379, decode_responses=True)
    
    # Produzir no stream
    stream_id = acp.stream_produce(
        agent_id="minimax",
        msg_type="COMMAND",
        action="review_code",
        payload={"file": "hermes.py", "line": 42},
        from_agent="glm"
    )
    print(f"GLM → minimax stream: COMMAND published (id={stream_id})")
    
    # Consumir do stream
    msgs = acp.stream_consume("minimax", group="test-group", consumer="test-consumer")
    print(f"GLM → Consumed from stream:minimax: {len(msgs)} message(s)")
    
    return [task_id, event_id, stream_id]


if __name__ == "__main__":
    print("ACP Redis — Testes de Comunicação\n")
    print("=" * 50)
    
    try:
        test_pubsub()
        test_stream()
        test_full_cycle()
        print("\n=== RESULTADO: Todos os testes concluídos ===")
    except Exception as e:
        print(f"\n=== ERRO: {e} ===")
        import traceback
        traceback.print_exc()