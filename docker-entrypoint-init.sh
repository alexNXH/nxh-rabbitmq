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

# Créer un script post-start pour configurer RabbitMQ
cat > /tmp/post-start.sh <<'POSTSTART'
#!/bin/bash
set -e

# Attendre moins longtemps initialement
echo "Giving RabbitMQ time to initialize..."
sleep 30

# Fonction pour attendre que RabbitMQ soit prêt
wait_for_rabbitmq() {
    echo "Waiting for RabbitMQ to be fully ready..."
    for i in {1..60}; do
        # Vérifier que RabbitMQ répond ET que le Management UI est accessible
        if rabbitmqctl status >/dev/null 2>&1 && \
           curl -s http://localhost:15672 >/dev/null 2>&1; then
            echo "RabbitMQ is ready!"
            return 0
        fi
        echo "Waiting for RabbitMQ and Management UI... ($i/60)"
        sleep 3
    done
    echo "RabbitMQ failed to start completely"
    return 1
}

wait_for_rabbitmq

echo "Starting post-configuration..."

# 1. Créer l'utilisateur principal si différent de celui par défaut
if [ "${NXH_RABBITMQ_USER}" != "${RABBITMQ_DEFAULT_USER}" ]; then
    echo "Creating user: ${NXH_RABBITMQ_USER}"
    rabbitmqctl add_user "${NXH_RABBITMQ_USER}" "${NXH_RABBITMQ_PASSWORD}" 2>/dev/null || \
    rabbitmqctl change_password "${NXH_RABBITMQ_USER}" "${NXH_RABBITMQ_PASSWORD}"
    
    rabbitmqctl set_user_tags "${NXH_RABBITMQ_USER}" administrator
    echo "User ${NXH_RABBITMQ_USER} created/updated"
fi

# 2. Créer l'utilisateur management si différent
if [ -n "${NXH_RABBITMQ_MGMT_USER}" ] && [ "${NXH_RABBITMQ_MGMT_USER}" != "${NXH_RABBITMQ_USER}" ]; then
    echo "Creating management user: ${NXH_RABBITMQ_MGMT_USER}"
    rabbitmqctl add_user "${NXH_RABBITMQ_MGMT_USER}" "${NXH_RABBITMQ_MGMT_PASSWORD}" 2>/dev/null || \
    rabbitmqctl change_password "${NXH_RABBITMQ_MGMT_USER}" "${NXH_RABBITMQ_MGMT_PASSWORD}"
    
    rabbitmqctl set_user_tags "${NXH_RABBITMQ_MGMT_USER}" administrator management
    echo "Management user ${NXH_RABBITMQ_MGMT_USER} created/updated"
fi

# 3. Créer le vhost si différent de /
if [ -n "${NXH_RABBITMQ_VHOST}" ] && [ "${NXH_RABBITMQ_VHOST}" != "/" ]; then
    echo "Creating vhost: ${NXH_RABBITMQ_VHOST}"
    rabbitmqctl add_vhost "${NXH_RABBITMQ_VHOST}" 2>/dev/null || true
    echo "VHost ${NXH_RABBITMQ_VHOST} created"
    
    # Donner les permissions à l'utilisateur principal sur le nouveau vhost
    echo "Setting permissions for ${NXH_RABBITMQ_USER} on ${NXH_RABBITMQ_VHOST}"
    rabbitmqctl set_permissions -p "${NXH_RABBITMQ_VHOST}" "${NXH_RABBITMQ_USER}" ".*" ".*" ".*"
    
    # Donner les permissions à l'utilisateur management si différent
    if [ -n "${NXH_RABBITMQ_MGMT_USER}" ] && [ "${NXH_RABBITMQ_MGMT_USER}" != "${NXH_RABBITMQ_USER}" ]; then
        rabbitmqctl set_permissions -p "${NXH_RABBITMQ_VHOST}" "${NXH_RABBITMQ_MGMT_USER}" ".*" ".*" ".*"
    fi

    echo "Permissions set on vhost ${NXH_RABBITMQ_VHOST}"
fi

# S'assurer que les utilisateurs ont les permissions sur le vhost par défaut /
rabbitmqctl set_permissions -p "/" "${NXH_RABBITMQ_USER}" ".*" ".*" ".*" 2>/dev/null || true
if [ -n "${NXH_RABBITMQ_MGMT_USER}" ] && [ "${NXH_RABBITMQ_MGMT_USER}" != "${NXH_RABBITMQ_USER}" ]; then
    rabbitmqctl set_permissions -p "/" "${NXH_RABBITMQ_MGMT_USER}" ".*" ".*" ".*" 2>/dev/null || true
fi

# 4. Créer la queue par défaut si spécifiée
if [ -n "${NXH_RABBITMQ_QUEUE}" ]; then
    echo "Creating default queue: ${NXH_RABBITMQ_QUEUE}"

    # Déterminer le vhost à utiliser
    VHOST_PARAM="${NXH_RABBITMQ_VHOST:-/}"
    
    # Créer la queue avec rabbitmqadmin
    rabbitmqadmin -u "${NXH_RABBITMQ_USER}" -p "${NXH_RABBITMQ_PASSWORD}" \
        -V "${VHOST_PARAM}" \
        declare queue name="${NXH_RABBITMQ_QUEUE}" durable=true auto_delete=false \
        2>/dev/null && echo "Queue ${NXH_RABBITMQ_QUEUE} created on vhost ${VHOST_PARAM}" || \
        echo "Queue might already exist or will be created on first use"
fi

echo ""
echo "=================================================="
echo "Post-start configuration completed!"
echo "=================================================="
echo ""
echo "Configuration Summary:"
echo "  - Default Admin: ${RABBITMQ_DEFAULT_USER}"
echo "  - Main User: ${NXH_RABBITMQ_USER}"
echo "  - Management User: ${NXH_RABBITMQ_MGMT_USER:-${NXH_RABBITMQ_USER}}"
echo "  - VHost: ${NXH_RABBITMQ_VHOST:-/}"
echo "  - Queue: ${NXH_RABBITMQ_QUEUE:-none}"
echo ""
echo "Access URLs:"
echo "  - Management UI: http://${NXH_RABBITMQ_HOST:-localhost}:${NXH_RABBITMQ_API_PORT}"
echo "  - AMQP: amqp://${NXH_RABBITMQ_USER}:***@${NXH_RABBITMQ_HOST:-localhost}:${NXH_RABBITMQ_PORT}${NXH_RABBITMQ_VHOST:-/}"
echo ""
echo "=================================================="
POSTSTART

chmod +x /tmp/post-start.sh

# Lancer le script post-start en arrière-plan
/tmp/post-start.sh &

# Exécuter l'entrypoint original de RabbitMQ
exec docker-entrypoint.sh "$@"