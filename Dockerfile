# Multi-stage Dockerfile pour RabbitMQ Custom
# Support: ARM64 et AMD64
# Base: Image officielle RabbitMQ avec management plugin

FROM rabbitmq:3.13-management-alpine AS base

# Metadata
LABEL maintainer="NXH Admin Sys Team"
LABEL description="Custom RabbitMQ service with pre-configured defaults"
LABEL version="1.0.0"

# Variables d'environnement par défaut
ENV NXH_RABBITMQ_DEFAULT_USER=nxh_admin
ENV NXH_RABBITMQ_DEFAULT_PASS=nxh_secure_password_2024
ENV RABBITMQ_DEFAULT_USER=${NXH_RABBITMQ_DEFAULT_USER}
ENV RABBITMQ_DEFAULT_PASS=${NXH_RABBITMQ_DEFAULT_PASS}

# Configuration RabbitMQ optimisée
ENV RABBITMQ_VM_MEMORY_HIGH_WATERMARK=0.6
ENV RABBITMQ_DISK_FREE_LIMIT=2GB

# Activer les plugins essentiels
RUN rabbitmq-plugins enable --offline \
    rabbitmq_management \
    rabbitmq_prometheus \
    rabbitmq_shovel \
    rabbitmq_shovel_management

# Créer les répertoires nécessaires
RUN mkdir -p /var/lib/rabbitmq && \
    chown -R rabbitmq:rabbitmq /var/lib/rabbitmq

# Healthcheck optimisé
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD rabbitmq-diagnostics -q ping && \
        rabbitmq-diagnostics -q check_running && \
        rabbitmq-diagnostics -q check_local_alarms

# Exposer les ports
# 5672: AMQP protocol
# 15672: Management UI
EXPOSE 5672 15672

# Volume pour la persistance
VOLUME /var/lib/rabbitmq

# Utiliser l'utilisateur non-root par défaut
USER rabbitmq

# Point d'entrée par défaut de l'image RabbitMQ
CMD ["rabbitmq-server"]