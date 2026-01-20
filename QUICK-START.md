# 🚀 Guide de Démarrage Rapide - Configuration pour Applications

## 📋 Variables d'Environnement à Fournir aux Applications

Voici les variables que vos applications doivent utiliser pour se connecter à RabbitMQ :

### Variables Essentielles

```bash
NXH_RABBITMQ_HOST=localhost           # ou l'IP/hostname de votre serveur
NXH_RABBITMQ_PORT=5672               # Port AMQP
NXH_RABBITMQ_API_PORT=15672          # Port Management UI
NXH_RABBITMQ_USER=nxh_admin          # Utilisateur pour connexions AMQP
NXH_RABBITMQ_PASSWORD=nxh_secure_password_2024  # Mot de passe
NXH_RABBITMQ_VHOST=/                 # Virtual Host
NXH_RABBITMQ_QUEUE=default_queue     # Queue par défaut
```

### Variables Optionnelles (Management)

```bash
NXH_RABBITMQ_MGMT_USER=nxh_admin             # User pour Management UI
NXH_RABBITMQ_MGMT_PASSWORD=nxh_secure_password_2024  # Password UI
```

---

## 🔧 Configuration Initiale

### Étape 1 : Créer votre fichier .env

```bash
# Dans le répertoire nxh-rabbitmq
cp .env.example .env
nano .env
```

### Étape 2 : Personnaliser les valeurs

```bash
# .env - Exemple pour environnement de développement
NXH_RABBITMQ_HOST=localhost
NXH_RABBITMQ_PORT=5672
NXH_RABBITMQ_API_PORT=15672
NXH_RABBITMQ_USER=dev_user
NXH_RABBITMQ_PASSWORD=dev_password_123
NXH_RABBITMQ_VHOST=/dev
NXH_RABBITMQ_QUEUE=dev_tasks_queue
```

### Étape 3 : Démarrer RabbitMQ

```bash
docker-compose up -d
```

### Étape 4 : Vérifier que tout fonctionne

```bash
# Vérifier les logs
docker-compose logs -f rabbitmq

# Chercher cette ligne :
# "✅ Post-start configuration completed"
# "Server startup complete; 7 plugins started."
```

---

## 📤 Exporter la Configuration pour vos Applications

### Option 1 : Export JSON (recommandé pour API)

```bash
./config-export.sh --json app-config.json
```

Résultat (`app-config.json`) :
```json
{
  "host": "localhost",
  "port": 5672,
  "api_port": 15672,
  "user": "dev_user",
  "password": "dev_password_123",
  "vhost": "/dev",
  "queue": "dev_tasks_queue",
  "amqp_url": "amqp://dev_user:dev_password_123@localhost:5672/dev",
  "management_url": "http://dev_user:dev_password_123@localhost:15672"
}
```

### Option 2 : Export YAML (pour config files)

```bash
./config-export.sh --yaml app-config.yaml
```

Résultat (`app-config.yaml`) :
```yaml
rabbitmq:
  host: localhost
  port: 5672
  user: dev_user
  password: dev_password_123
  vhost: /dev
  queue: dev_tasks_queue
  amqp_url: "amqp://dev_user:dev_password_123@localhost:5672/dev"
```

### Option 3 : Export .env (pour Docker Compose)

```bash
./config-export.sh --env my-app.env
```

Résultat (`my-app.env`) :
```bash
NXH_RABBITMQ_HOST=localhost
NXH_RABBITMQ_PORT=5672
NXH_RABBITMQ_USER=dev_user
NXH_RABBITMQ_PASSWORD=dev_password_123
NXH_RABBITMQ_VHOST=/dev
NXH_RABBITMQ_QUEUE=dev_tasks_queue
```

---

## 🔗 URLs de Connexion

### URL AMQP (pour applications)

```
amqp://[USER]:[PASSWORD]@[HOST]:[PORT][VHOST]
```

**Exemple** :
```
amqp://dev_user:dev_password_123@localhost:5672/dev
```

### URL Management UI

```
http://[HOST]:[API_PORT]
```

**Exemple** :
```
http://localhost:15672
```

---

## 💻 Exemples d'Utilisation dans vos Applications

### Python (avec pika)

```python
import pika
import os

# Charger depuis les variables d'environnement
credentials = pika.PlainCredentials(
    os.getenv('NXH_RABBITMQ_USER', 'nxh_admin'),
    os.getenv('NXH_RABBITMQ_PASSWORD', 'nxh_secure_password_2024')
)

connection = pika.BlockingConnection(
    pika.ConnectionParameters(
        host=os.getenv('NXH_RABBITMQ_HOST', 'localhost'),
        port=int(os.getenv('NXH_RABBITMQ_PORT', 5672)),
        virtual_host=os.getenv('NXH_RABBITMQ_VHOST', '/'),
        credentials=credentials
    )
)

channel = connection.channel()
queue_name = os.getenv('NXH_RABBITMQ_QUEUE', 'default_queue')
channel.queue_declare(queue=queue_name, durable=True)

# Publier
channel.basic_publish(
    exchange='',
    routing_key=queue_name,
    body='Hello RabbitMQ!'
)

connection.close()
```

### Node.js (avec amqplib)

```javascript
const amqp = require('amqplib');

const config = {
  host: process.env.NXH_RABBITMQ_HOST || 'localhost',
  port: process.env.NXH_RABBITMQ_PORT || 5672,
  user: process.env.NXH_RABBITMQ_USER || 'nxh_admin',
  password: process.env.NXH_RABBITMQ_PASSWORD || 'nxh_secure_password_2024',
  vhost: process.env.NXH_RABBITMQ_VHOST || '/',
  queue: process.env.NXH_RABBITMQ_QUEUE || 'default_queue'
};

const amqpUrl = `amqp://${config.user}:${config.password}@${config.host}:${config.port}${config.vhost}`;

async function connect() {
  const connection = await amqp.connect(amqpUrl);
  const channel = await connection.createChannel();
  
  await channel.assertQueue(config.queue, { durable: true });
  await channel.sendToQueue(config.queue, Buffer.from('Hello RabbitMQ!'));
  
  await connection.close();
}

connect();
```

### Java (avec Spring AMQP)

```yaml
# application.yml
spring:
  rabbitmq:
    host: ${NXH_RABBITMQ_HOST:localhost}
    port: ${NXH_RABBITMQ_PORT:5672}
    username: ${NXH_RABBITMQ_USER:nxh_admin}
    password: ${NXH_RABBITMQ_PASSWORD:nxh_secure_password_2024}
    virtual-host: ${NXH_RABBITMQ_VHOST:/}
```

### Docker Compose (pour vos applications)

```yaml
# docker-compose.yml de votre application
version: '3.8'

services:
  my-app:
    image: my-app:latest
    env_file:
      - rabbitmq-config.env  # Fichier généré par config-export.sh
    # Ou directement :
    environment:
      - NXH_RABBITMQ_HOST=nxh-rabbitmq
      - NXH_RABBITMQ_PORT=5672
      - NXH_RABBITMQ_USER=${NXH_RABBITMQ_USER}
      - NXH_RABBITMQ_PASSWORD=${NXH_RABBITMQ_PASSWORD}
      - NXH_RABBITMQ_VHOST=${NXH_RABBITMQ_VHOST}
      - NXH_RABBITMQ_QUEUE=${NXH_RABBITMQ_QUEUE}
```

---

## 🌍 Configurations par Environnement

### Développement

```bash
NXH_RABBITMQ_HOST=localhost
NXH_RABBITMQ_USER=dev_user
NXH_RABBITMQ_PASSWORD=dev123
NXH_RABBITMQ_VHOST=/dev
NXH_RABBITMQ_QUEUE=dev_queue
```

### Staging

```bash
NXH_RABBITMQ_HOST=rabbitmq-staging.internal
NXH_RABBITMQ_USER=staging_user
NXH_RABBITMQ_PASSWORD=staging_secure_pass
NXH_RABBITMQ_VHOST=/staging
NXH_RABBITMQ_QUEUE=staging_queue
```

### Production

```bash
NXH_RABBITMQ_HOST=rabbitmq-prod.internal
NXH_RABBITMQ_USER=prod_user
NXH_RABBITMQ_PASSWORD=very_secure_production_password
NXH_RABBITMQ_VHOST=/production
NXH_RABBITMQ_QUEUE=prod_queue
```

---

## 🔐 Bonnes Pratiques

### 1. Ne jamais commiter les credentials

```bash
# Ajouté automatiquement dans .gitignore
.env
rabbitmq-config.*
```

### 2. Utiliser des secrets en production

```bash
# Kubernetes
kubectl create secret generic rabbitmq-credentials \
  --from-literal=user=prod_user \
  --from-literal=password=$(openssl rand -base64 32)

# Docker Swarm
echo "very_secure_password" | docker secret create rabbitmq_password -
```

### 3. Changer les credentials par défaut

```bash
# Toujours changer ces valeurs :
NXH_RABBITMQ_USER=votre_user_unique
NXH_RABBITMQ_PASSWORD=$(openssl rand -base64 32)
```

### 4. Utiliser des VHosts différents par environnement

```bash
# Dev
NXH_RABBITMQ_VHOST=/dev

# Staging
NXH_RABBITMQ_VHOST=/staging

# Prod
NXH_RABBITMQ_VHOST=/production
```

---

## 🧪 Tester la Configuration

```bash
# 1. Exporter la config
./config-export.sh --all

# 2. Vérifier les URLs
./config-export.sh --urls

# 3. Tester la connexion
python3 << EOF
import pika
import os

# Charger config
exec(open('rabbitmq-config.env').read())
creds = pika.PlainCredentials(NXH_RABBITMQ_USER, NXH_RABBITMQ_PASSWORD)
conn = pika.BlockingConnection(
    pika.ConnectionParameters(NXH_RABBITMQ_HOST, credentials=creds)
)
print("✅ Connexion réussie !")
conn.close()
EOF
```

---

## 📚 Prochaines Étapes

1. ✅ Configurer RabbitMQ avec vos variables
2. ✅ Exporter la configuration
3. ✅ Intégrer dans vos applications
4. 📖 Lire la [documentation complète](README.md)
5. 🚀 Déployer en production

---

**Support** : Pour toute question, consultez le [README.md](README.md) complet ou ouvrez une issue.