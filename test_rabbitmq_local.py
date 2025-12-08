#!/usr/bin/env python3
"""
Script de test RabbitMQ - Publier et Consommer des messages
Usage: python test_rabbitmq_local.py
"""
import pika
import sys

# Configuration
RABBITMQ_HOST = 'localhost'
RABBITMQ_PORT = 5672
RABBITMQ_USER = 'admin'
RABBITMQ_PASS = 'admin'

def test_connection():
    """Test la connexion à RabbitMQ"""
    print("🔌 Test de connexion à RabbitMQ...")
    try:
        credentials = pika.PlainCredentials(RABBITMQ_USER, RABBITMQ_PASS)
        connection = pika.BlockingConnection(
            pika.ConnectionParameters(
                host=RABBITMQ_HOST,
                port=RABBITMQ_PORT,
                credentials=credentials
            )
        )
        print("✅ Connexion réussie !")
        connection.close()
        return True
    except Exception as e:
        print(f"❌ Erreur de connexion : {e}")
        return False

def publish_messages(num_messages=5):
    """Publie des messages dans une queue"""
    print(f"\n📤 Publication de {num_messages} messages...")
    
    credentials = pika.PlainCredentials(RABBITMQ_USER, RABBITMQ_PASS)
    connection = pika.BlockingConnection(
        pika.ConnectionParameters(host=RABBITMQ_HOST, credentials=credentials)
    )
    channel = connection.channel()
    
    # Créer une queue durable
    queue_name = 'test_queue'
    channel.queue_declare(queue=queue_name, durable=True)
    
    # Publier les messages
    for i in range(1, num_messages + 1):
        message = f'Test message {i}'
        channel.basic_publish(
            exchange='',
            routing_key=queue_name,
            body=message,
            properties=pika.BasicProperties(delivery_mode=2)  # Message persistant
        )
        print(f"  ✅ Envoyé : {message}")
    
    connection.close()
    print(f"📊 {num_messages} messages publiés avec succès !")

def consume_messages():
    """Consomme les messages de la queue"""
    print("\n📥 Consommation des messages...\n")
    
    credentials = pika.PlainCredentials(RABBITMQ_USER, RABBITMQ_PASS)
    connection = pika.BlockingConnection(
        pika.ConnectionParameters(host=RABBITMQ_HOST, credentials=credentials)
    )
    channel = connection.channel()
    
    queue_name = 'test_queue'
    
    # Consommer tous les messages disponibles
    message_count = 0
    while True:
        method, properties, body = channel.basic_get(queue=queue_name, auto_ack=True)
        if body:
            message_count += 1
            print(f"  ✅ Reçu : {body.decode()}")
        else:
            break
    
    connection.close()
    
    if message_count > 0:
        print(f"\n📊 {message_count} message(s) consommé(s) avec succès !")
    else:
        print("\n⚠️  Aucun message dans la queue")

def get_queue_info():
    """Récupère les infos sur la queue via l'API"""
    print("\n📊 Informations sur la queue...")
    import requests
    from requests.auth import HTTPBasicAuth
    
    try:
        response = requests.get(
            f'http://{RABBITMQ_HOST}:15672/api/queues/%2F/test_queue',
            auth=HTTPBasicAuth(RABBITMQ_USER, RABBITMQ_PASS)
        )
        
        if response.status_code == 200:
            data = response.json()
            print(f"  📦 Nom : {data.get('name')}")
            print(f"  💾 Messages prêts : {data.get('messages_ready', 0)}")
            print(f"  🔄 Messages non-ackés : {data.get('messages_unacknowledged', 0)}")
            print(f"  📈 Total messages : {data.get('messages', 0)}")
        else:
            print(f"  ⚠️  Queue non trouvée ou API inaccessible")
    except Exception as e:
        print(f"  ⚠️  Impossible de récupérer les infos : {e}")

def main():
    print("=" * 60)
    print("🐰 Test RabbitMQ - NXH Custom Image")
    print("=" * 60)
    
    # Test 1 : Connexion
    if not test_connection():
        print("\n❌ Impossible de se connecter. Vérifiez que RabbitMQ est démarré.")
        sys.exit(1)
    
    # Test 2 : Publication
    publish_messages(5)
    
    # Test 3 : Info queue (optionnel)
    try:
        get_queue_info()
    except:
        pass
    
    # Test 4 : Consommation
    consume_messages()
    
    print("\n" + "=" * 60)
    print("✅ Tous les tests sont passés avec succès !")
    print("=" * 60)

if __name__ == '__main__':
    main()