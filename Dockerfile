# Multi-stage Dockerfile pour RabbitMQ Custom
# Support: ARM64 et AMD64
# Base: Image officielle RabbitMQ avec management plugin

FROM rabbitmq:3.13-management-alpine AS base

# Metadata
LABEL maintainer="NXH Admin SYS Team"
LABEL description="Custom RabbitMQ service with pre-configured defaults"
LABEL version="1.0.1"

# Variables d'environnement pour les credentials uniquement
ENV NXH_RABBITMQ_DEFAULT_USER=nxh_admin
ENV NXH_RABBITMQ_DEFAULT_PASS=nxh_secure_password_2024
ENV RABBITMQ_DEFAULT_USER=${NXH_RABBITMQ_DEFAULT_USER}
ENV RABBITMQ_DEFAULT_PASS=${NXH_RABBITMQ_DEFAULT_PASS}

# Activer les plugins essentiels
RUN rabbitmq-plugins enable --offline \
    rabbitmq_management \
    rabbitmq_prometheus \
    rabbitmq_shovel \
    rabbitmq_shovel_management

# Créer le fichier de configuration RabbitMQ
RUN mkdir -p /etc/rabbitmq && \
    cat > /etc/rabbitmq/rabbitmq.conf <<EOF
# Configuration RabbitMQ optimisée
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

## Default vhost
default_vhost = /
default_user = ${NXH_RABBITMQ_DEFAULT_USER}
default_pass = ${NXH_RABBITMQ_DEFAULT_PASS}
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
# 5672: AMQP protocol
# 443: Management UI
EXPOSE 5672
EXPOSE 15672

# Volume pour la persistance
VOLUME /var/lib/rabbitmq

# Utiliser l'utilisateur non-root par défaut
USER rabbitmq

# Point d'entrée par défaut de l'image RabbitMQ
CMD ["rabbitmq-server"]