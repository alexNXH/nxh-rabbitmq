#!/bin/bash
# Script d'initialisation RabbitMQ avec configuration NXH avancée

set -e

echo "=================================================="
echo "NXH RabbitMQ - Configuration avancée"
echo "=================================================="

# Afficher la configuration (sans les mots de passe)
echo "Configuration:"
echo "  - Host: ${NXH_RABBITMQ_HOST}"
echo "  - Port AMQP: ${NXH_RABBITMQ_PORT}"
echo "  - Port API: ${NXH_RABBITMQ_API_PORT}"
echo "  - User: ${NXH_RABBITMQ_USER}"
echo "  - Management User: ${NXH_RABBITMQ_MGMT_USER}"
echo "  - VHost: ${NXH_RABBITMQ_VHOST}"
echo "  - Default Queue: ${NXH_RABBITMQ_QUEUE}"
echo "=================================================="

# Créer le fichier de définitions pour l'initialisation automatique
cat > /etc/rabbitmq/definitions.json <<EOF
{
  "rabbit_version": "3.13.7",
  "rabbitmq_version": "3.13.7",
  "product_name": "RabbitMQ",
  "product_version": "3.13.7",
  "users": [
    {
      "name": "${NXH_RABBITMQ_USER}",
      "password_hash": "",
      "hashing_algorithm": "rabbit_password_hashing_sha256",
      "tags": ["administrator"],
      "limits": {}
    }
  ],
  "vhosts": [
    {
      "name": "${NXH_RABBITMQ_VHOST}"
    }
  ],
  "permissions": [
    {
      "user": "${NXH_RABBITMQ_USER}",
      "vhost": "${NXH_RABBITMQ_VHOST}",
      "configure": ".*",
      "write": ".*",
      "read": ".*"
    }
  ],
  "queues": [
    {
      "name": "${NXH_RABBITMQ_QUEUE}",
      "vhost": "${NXH_RABBITMQ_VHOST}",
      "durable": true,
      "auto_delete": false,
      "arguments": {}
    }
  ],
  "exchanges": [],
  "bindings": []
}
EOF

# Créer un script post-start pour créer les ressources si besoin
cat > /tmp/post-start.sh <<'POSTSTART'
#!/bin/bash
# Attendre que RabbitMQ soit complètement démarré
sleep 15

# Créer le vhost si différent de /
if [ "${NXH_RABBITMQ_VHOST}" != "/" ]; then
  echo "Creating vhost: ${NXH_RABBITMQ_VHOST}"
  rabbitmqctl add_vhost "${NXH_RABBITMQ_VHOST}" 2>/dev/null || true
  rabbitmqctl set_permissions -p "${NXH_RABBITMQ_VHOST}" "${NXH_RABBITMQ_USER}" ".*" ".*" ".*" 2>/dev/null || true
fi

# Créer la queue par défaut
if [ -n "${NXH_RABBITMQ_QUEUE}" ]; then
  echo "Creating default queue: ${NXH_RABBITMQ_QUEUE}"
  
  # Utiliser l'API REST pour créer la queue
  sleep 5
  curl -u "${NXH_RABBITMQ_USER}:${NXH_RABBITMQ_PASSWORD}" \
    -X PUT \
    -H "Content-Type: application/json" \
    -d '{"durable":true,"auto_delete":false}' \
    "http://localhost:15672/api/queues/${NXH_RABBITMQ_VHOST//\//%2F}/${NXH_RABBITMQ_QUEUE}" \
    2>/dev/null || true
fi

echo "Post-start configuration completed"
POSTSTART

chmod +x /tmp/post-start.sh

# Lancer le script post-start en arrière-plan
/tmp/post-start.sh &

# Exécuter l'entrypoint original de RabbitMQ
exec docker-entrypoint.sh "$@"