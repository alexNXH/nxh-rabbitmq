#!/bin/bash
# Script pour exporter la configuration RabbitMQ pour d'autres applications

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ENV_FILE="${SCRIPT_DIR}/.env"

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=================================================="
echo "📋 NXH RabbitMQ - Export de Configuration"
echo "=================================================="
echo ""

# Charger le fichier .env si existe
if [ -f "$ENV_FILE" ]; then
    export $(cat "$ENV_FILE" | grep -v '^#' | xargs)
    echo -e "${GREEN}✅ Configuration chargée depuis .env${NC}"
else
    echo -e "${YELLOW}⚠️  Fichier .env non trouvé, utilisation des valeurs par défaut${NC}"
fi

# Valeurs par défaut si non définies
NXH_RABBITMQ_HOST=${NXH_RABBITMQ_HOST:-localhost}
NXH_RABBITMQ_PORT=${NXH_RABBITMQ_PORT:-5672}
NXH_RABBITMQ_API_PORT=${NXH_RABBITMQ_API_PORT:-15672}
NXH_RABBITMQ_USER=${NXH_RABBITMQ_USER:-nxh_admin}
NXH_RABBITMQ_PASSWORD=${NXH_RABBITMQ_PASSWORD:-nxh_secure_password_2024}
NXH_RABBITMQ_MGMT_USER=${NXH_RABBITMQ_MGMT_USER:-$NXH_RABBITMQ_USER}
NXH_RABBITMQ_MGMT_PASSWORD=${NXH_RABBITMQ_MGMT_PASSWORD:-$NXH_RABBITMQ_PASSWORD}
NXH_RABBITMQ_VHOST=${NXH_RABBITMQ_VHOST:-/}
NXH_RABBITMQ_QUEUE=${NXH_RABBITMQ_QUEUE:-default_queue}

# Fonction pour afficher la config
display_config() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📊 Configuration RabbitMQ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  NXH_RABBITMQ_HOST=$NXH_RABBITMQ_HOST"
    echo "  NXH_RABBITMQ_PORT=$NXH_RABBITMQ_PORT"
    echo "  NXH_RABBITMQ_API_PORT=$NXH_RABBITMQ_API_PORT"
    echo "  NXH_RABBITMQ_USER=$NXH_RABBITMQ_USER"
    echo "  NXH_RABBITMQ_PASSWORD=$NXH_RABBITMQ_PASSWORD"
    echo "  NXH_RABBITMQ_MGMT_USER=$NXH_RABBITMQ_MGMT_USER"
    echo "  NXH_RABBITMQ_MGMT_PASSWORD=$NXH_RABBITMQ_MGMT_PASSWORD"
    echo "  NXH_RABBITMQ_VHOST=$NXH_RABBITMQ_VHOST"
    echo "  NXH_RABBITMQ_QUEUE=$NXH_RABBITMQ_QUEUE"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Fonction pour exporter en format .env
export_env() {
    OUTPUT_FILE="${1:-rabbitmq-config.env}"
    
    cat > "$OUTPUT_FILE" <<EOF
# Configuration RabbitMQ - Généré le $(date)
NXH_RABBITMQ_HOST=$NXH_RABBITMQ_HOST
NXH_RABBITMQ_PORT=$NXH_RABBITMQ_PORT
NXH_RABBITMQ_API_PORT=$NXH_RABBITMQ_API_PORT
NXH_RABBITMQ_USER=$NXH_RABBITMQ_USER
NXH_RABBITMQ_PASSWORD=$NXH_RABBITMQ_PASSWORD
NXH_RABBITMQ_MGMT_USER=$NXH_RABBITMQ_MGMT_USER
NXH_RABBITMQ_MGMT_PASSWORD=$NXH_RABBITMQ_MGMT_PASSWORD
NXH_RABBITMQ_VHOST=$NXH_RABBITMQ_VHOST
NXH_RABBITMQ_QUEUE=$NXH_RABBITMQ_QUEUE
EOF
    
    echo -e "${GREEN}✅ Configuration exportée vers: $OUTPUT_FILE${NC}"
}

# Fonction pour exporter en JSON
export_json() {
    OUTPUT_FILE="${1:-rabbitmq-config.json}"
    
    cat > "$OUTPUT_FILE" <<EOF
{
  "host": "$NXH_RABBITMQ_HOST",
  "port": $NXH_RABBITMQ_PORT,
  "api_port": $NXH_RABBITMQ_API_PORT,
  "user": "$NXH_RABBITMQ_USER",
  "password": "$NXH_RABBITMQ_PASSWORD",
  "mgmt_user": "$NXH_RABBITMQ_MGMT_USER",
  "mgmt_password": "$NXH_RABBITMQ_MGMT_PASSWORD",
  "vhost": "$NXH_RABBITMQ_VHOST",
  "queue": "$NXH_RABBITMQ_QUEUE",
  "amqp_url": "amqp://$NXH_RABBITMQ_USER:$NXH_RABBITMQ_PASSWORD@$NXH_RABBITMQ_HOST:$NXH_RABBITMQ_PORT$NXH_RABBITMQ_VHOST",
  "management_url": "http://$NXH_RABBITMQ_MGMT_USER:$NXH_RABBITMQ_MGMT_PASSWORD@$NXH_RABBITMQ_HOST:$NXH_RABBITMQ_API_PORT"
}
EOF
    
    echo -e "${GREEN}✅ Configuration exportée vers: $OUTPUT_FILE${NC}"
}

# Fonction pour exporter en YAML
export_yaml() {
    OUTPUT_FILE="${1:-rabbitmq-config.yaml}"
    
    cat > "$OUTPUT_FILE" <<EOF
# Configuration RabbitMQ - Généré le $(date)
rabbitmq:
  host: $NXH_RABBITMQ_HOST
  port: $NXH_RABBITMQ_PORT
  api_port: $NXH_RABBITMQ_API_PORT
  user: $NXH_RABBITMQ_USER
  password: $NXH_RABBITMQ_PASSWORD
  mgmt_user: $NXH_RABBITMQ_MGMT_USER
  mgmt_password: $NXH_RABBITMQ_MGMT_PASSWORD
  vhost: $NXH_RABBITMQ_VHOST
  queue: $NXH_RABBITMQ_QUEUE
  amqp_url: "amqp://$NXH_RABBITMQ_USER:$NXH_RABBITMQ_PASSWORD@$NXH_RABBITMQ_HOST:$NXH_RABBITMQ_PORT$NXH_RABBITMQ_VHOST"
  management_url: "http://$NXH_RABBITMQ_MGMT_USER:$NXH_RABBITMQ_MGMT_PASSWORD@$NXH_RABBITMQ_HOST:$NXH_RABBITMQ_API_PORT"
EOF
    
    echo -e "${GREEN}✅ Configuration exportée vers: $OUTPUT_FILE${NC}"
}

# Fonction pour générer l'URL de connexion
generate_urls() {
    echo ""
    echo -e "${BLUE}🔗 URLs de Connexion${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  AMQP URL:"
    echo "    amqp://$NXH_RABBITMQ_USER:$NXH_RABBITMQ_PASSWORD@$NXH_RABBITMQ_HOST:$NXH_RABBITMQ_PORT$NXH_RABBITMQ_VHOST"
    echo ""
    echo "  Management UI:"
    echo "    http://$NXH_RABBITMQ_HOST:$NXH_RABBITMQ_API_PORT"
    echo ""
    echo "  Management API:"
    echo "    http://$NXH_RABBITMQ_MGMT_USER:$NXH_RABBITMQ_MGMT_PASSWORD@$NXH_RABBITMQ_HOST:$NXH_RABBITMQ_API_PORT"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Menu principal
show_menu() {
    echo ""
    echo "Que voulez-vous faire ?"
    echo "  1) Afficher la configuration"
    echo "  2) Exporter en .env"
    echo "  3) Exporter en JSON"
    echo "  4) Exporter en YAML"
    echo "  5) Générer les URLs de connexion"
    echo "  6) Tout exporter"
    echo "  0) Quitter"
    echo ""
    read -p "Votre choix [0-6]: " choice
    
    case $choice in
        1)
            display_config
            show_menu
            ;;
        2)
            read -p "Nom du fichier [rabbitmq-config.env]: " filename
            export_env "${filename:-rabbitmq-config.env}"
            show_menu
            ;;
        3)
            read -p "Nom du fichier [rabbitmq-config.json]: " filename
            export_json "${filename:-rabbitmq-config.json}"
            show_menu
            ;;
        4)
            read -p "Nom du fichier [rabbitmq-config.yaml]: " filename
            export_yaml "${filename:-rabbitmq-config.yaml}"
            show_menu
            ;;
        5)
            generate_urls
            show_menu
            ;;
        6)
            export_env
            export_json
            export_yaml
            generate_urls
            echo ""
            echo -e "${GREEN}✅ Toutes les configurations ont été exportées${NC}"
            ;;
        0)
            echo "Au revoir !"
            exit 0
            ;;
        *)
            echo -e "${YELLOW}Choix invalide${NC}"
            show_menu
            ;;
    esac
}

# Démarrer le menu si mode interactif
if [ "$1" == "" ]; then
    display_config
    show_menu
else
    # Mode non-interactif
    case "$1" in
        --env)
            export_env "$2"
            ;;
        --json)
            export_json "$2"
            ;;
        --yaml)
            export_yaml "$2"
            ;;
        --urls)
            generate_urls
            ;;
        --all)
            export_env
            export_json
            export_yaml
            ;;
        *)
            echo "Usage: $0 [--env|--json|--yaml|--urls|--all] [output_file]"
            exit 1
            ;;
    esac
fi