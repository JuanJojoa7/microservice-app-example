#!/usr/bin/env python3
import redis
import json
import time

# Conectar a Redis
r = redis.Redis(host='localhost', port=6379, db=0)

# Suscribirse al canal de logs
pubsub = r.pubsub()
pubsub.subscribe(['log_channel'])

print("🚀 Monitor de logging iniciado...")
print("📝 Cuando crees o elimines TODOs, aparecerán aquí:")
print("-" * 50)

for message in pubsub.listen():
    if message['type'] == 'message':
        try:
            data = json.loads(message['data'].decode('utf-8'))
            timestamp = time.strftime('%H:%M:%S')
            print(f"[{timestamp}] 📋 {data['opName']} - Usuario: {data['username']}, TODO ID: {data['todoId']}")
        except:
            print(f"[{time.strftime('%H:%M:%S')}] 📨 Mensaje recibido: {message['data']}")