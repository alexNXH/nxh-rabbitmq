#!/bin/bash
set -euo pipefail

# Appliquer les variables d'environnement custom
if [[ -n "${NXH_RABBITMQ_DEFAULT_USER:-}" ]] && [[ -n "${NXH_RABBITMQ_DEFAULT_PASS:-}" ]]; then
    export RABBITMQ_DEFAULT_USER="${NXH_RABBITMQ_DEFAULT_USER}"
    export RABBITMQ_DEFAULT_PASS="${NXH_RABBITMQ_DEFAULT_PASS}"
fi

# Configuration du cookie Erlang pour le clustering
if [[ -n "${RABBITMQ_ERLANG_COOKIE:-}" ]]; then
    cookie_file="/var/lib/rabbitmq/.erlang.cookie"
    if [[ ! -f "${cookie_file}" ]]; then
        echo "${RABBITMQ_ERLANG_COOKIE}" > "${cookie_file}"
        chmod 600 "${cookie_file}"
        chown rabbitmq:rabbitmq "${cookie_file}"
    fi
fi

# Démarrer RabbitMQ
exec gosu rabbitmq "$@"
