# Build stage pour les dépendances
FROM alpine:3.19 AS builder

# Installer les outils nécessaires pour la compilation
RUN apk add --no-cache \
    curl \
    tar \
    xz \
    gcc \
    g++ \
    make \
    python3 \
    perl \
    linux-headers \
    ncurses-dev \
    openssl-dev \
    coreutils \
    bash

# Variables pour RabbitMQ
ARG RABBITMQ_VERSION=3.13.2
ARG RABBITMQ_SHA256=a71a5caa97e2b6dbb5e9a7b14daa8b77df0a18c63583af130d48c2031ca2e10a
ARG RABBITMQ_HOME=/opt/rabbitmq
ARG ERLANG_VERSION=26.2.2

# Télécharger et installer Erlang
RUN set -eux; \
    ERLANG_DOWNLOAD_URL="https://github.com/erlang/otp/releases/download/OTP-${ERLANG_VERSION}/otp_src_${ERLANG_VERSION}.tar.gz"; \
    curl -fSL -o otp-src.tar.gz "$ERLANG_DOWNLOAD_URL"; \
    mkdir -p /usr/local/src/otp-src; \
    tar -xzf otp-src.tar.gz -C /usr/local/src/otp-src --strip-components=1; \
    rm otp-src.tar.gz; \
    cd /usr/local/src/otp-src; \
    ./configure \
        --prefix=/usr/local/erlang \
        --enable-smp-support \
        --enable-m64-build \
        --disable-hipe \
        --without-javac \
        --without-wx \
        --without-debugger \
        --without-observer \
        --without-jinterface \
        --without-cosEvent \
        --without-cosEventDomain \
        --without-cosFileTransfer \
        --without-cosNotification \
        --without-cosProperty \
        --without-cosTime \
        --without-cosTransactions \
        --without-et \
        --without-gs \
        --without-odbc \
        --without-erl_interface; \
    make -j$(getconf _NPROCESSORS_ONLN); \
    make install; \
    rm -rf /usr/local/src/otp-src;

# Télécharger et installer RabbitMQ
RUN set -eux; \
    RABBITMQ_DOWNLOAD_URL="https://github.com/rabbitmq/rabbitmq-server/releases/download/v${RABBITMQ_VERSION}/rabbitmq-server-generic-unix-${RABBITMQ_VERSION}.tar.xz"; \
    curl -fSL -o rabbitmq.tar.xz "$RABBITMQ_DOWNLOAD_URL"; \
    echo "${RABBITMQ_SHA256} *rabbitmq.tar.xz" | sha256sum -c -; \
    mkdir -p "$RABBITMQ_HOME"; \
    tar -xJf rabbitmq.tar.xz -C "$RABBITMQ_HOME" --strip-components 1; \
    rm rabbitmq.tar.xz;

# Stage final minimal
FROM alpine:3.19

# Variables d'environnement
ENV RABBITMQ_HOME=/opt/rabbitmq \
    PATH=/opt/rabbitmq/sbin:/usr/local/erlang/bin:$PATH \
    RABBITMQ_DATA_DIR=/var/lib/rabbitmq \
    RABBITMQ_LOGS=- \
    RABBITMQ_SASL_LOGS=- \
    NXH_RABBITMQ_DEFAULT_USER=admin \
    NXH_RABBITMQ_DEFAULT_PASS=admin123 \
    RABBITMQ_DEFAULT_VHOST=/ \
    RABBITMQ_ERLANG_COOKIE=NXH_RABBITMQ_SECURE_COOKIE

# Installation des dépendances runtime
RUN apk add --no-cache \
    ca-certificates \
    curl \
    bash \
    procps \
    su-exec \
    tzdata \
    xmlstarlet \
    openssl \
    coreutils \
    ncurses

# Création de l'utilisateur et groupe rabbitmq
RUN addgroup -S rabbitmq && adduser -S rabbitmq -G rabbitmq

# Copier Erlang et RabbitMQ depuis le builder
COPY --from=builder /usr/local/erlang /usr/local/erlang
COPY --from=builder /opt/rabbitmq /opt/rabbitmq

# Copier les scripts de configuration
COPY docker-entrypoint.sh /usr/local/bin/
COPY rabbitmq.conf /etc/rabbitmq/rabbitmq.conf

# Créer les répertoires nécessaires
RUN mkdir -p /var/lib/rabbitmq /etc/rabbitmq && \
    chown -R rabbitmq:rabbitmq /var/lib/rabbitmq /etc/rabbitmq && \
    chmod -R 775 /var/lib/rabbitmq /etc/rabbitmq && \
    chmod +x /usr/local/bin/docker-entrypoint.sh && \
    ln -sf /opt/rabbitmq/sbin/* /usr/local/sbin/

# Ports exposés
EXPOSE 5672 15672 25672 4369 9100 9101 9102 9103 9104 9105

# Volume pour les données persistantes
VOLUME /var/lib/rabbitmq

# Point d'entrée
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["rabbitmq-server"]