# Multi-stage Dockerfile pour RabbitMQ Custom
# Support: ARM64 et AMD64
# Base: Image officielle RabbitMQ avec management plugin

FROM rabbitmq:3.13-management-alpine AS base

# Metadata
LABEL maintainer="NXH AdminSys Team"
LABEL description="Custom RabbitMQ service with advanced configuration"
LABEL version="1.1.0"

# Variables d'environnement - Configuration principale
ENV NXH_RABBITMQ_HOST=localhost
ENV NXH_RABBITMQ_PORT=5672
ENV NXH_RABBITMQ_API_PORT=15672

# Variables d'environnement - Credentials utilisateur principal
ENV NXH_RABBITMQ_USER=nxh_admin
ENV NXH_RABBITMQ_PASSWORD=nxh_secure_password_2024

# Variables d'environnement - Credentials management (par défaut = user principal)
ENV NXH_RABBITMQ_MGMT_USER=${NXH_RABBITMQ_USER}
ENV NXH_RABBITMQ_MGMT_PASSWORD=${NXH_RABBITMQ_PASSWORD}

# Variables d'environnement - VHost et Queue
ENV NXH_RABBITMQ_VHOST=/
ENV NXH_RABBITMQ_QUEUE=default_queue

# Mapping vers les variables RabbitMQ standard
ENV RABBITMQ_DEFAULT_USER=${NXH_RABBITMQ_USER}
ENV RABBITMQ_DEFAULT_PASS=${NXH_RABBITMQ_PASSWORD}
ENV RABBITMQ_DEFAULT_VHOST=${NXH_RABBITMQ_VHOST}

# Activer les plugins essentiels
RUN rabbitmq-plugins enable --offline \
    rabbitmq_management \
    rabbitmq_prometheus \
    rabbitmq_shovel \
    rabbitmq_shovel_management

# Copier le script d'initialisation
COPY docker-entrypoint-init.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint-init.sh

# Créer le fichier de configuration RabbitMQ
RUN mkdir -p /etc/rabbitmq && \
    cat > /etc/rabbitmq/rabbitmq.conf <<EOF
# Configuration RabbitMQ NXH
# https://www.rabbitmq.com/configure.html

## Memory
vm_memory_high_watermark.relative = 0.6

## Disk
disk_free_limit.absolute = 2GB

## Networking
listeners.tcp.default = 5672

## Management Plugin
management.tcp.port = 15672
management.tcp.ip = 0.0.0.0

## Clustering (désactivé par défaut)
cluster_formation.peer_discovery_backend = rabbit_peer_discovery_classic_config

## Logging
log.console = true
log.console.level = info
log.file = false

## Default permissions
default_permissions.configure = .*
default_permissions.read = .*
default_permissions.write = .*
EOF

# Créer les répertoires nécessaires
RUN mkdir -p /var/lib/rabbitmq && \
    chown -R rabbitmq:rabbitmq /var/lib/rabbitmq /etc/rabbitmq

# Healthcheck optimisé
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD rabbitmq-diagnostics -q ping && \
        rabbitmq-diagnostics -q check_running && \
        rabbitmq-diagnostics -q check_local_alarms

# Exposer les ports
EXPOSE ${NXH_RABBITMQ_PORT} ${NXH_RABBITMQ_API_PORT}

# Volume pour la persistance
VOLUME /var/lib/rabbitmq

# Utiliser l'utilisateur non-root par défaut
USER rabbitmq

# Wrapper pour l'entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint-init.sh"]
CMD ["rabbitmq-server"]