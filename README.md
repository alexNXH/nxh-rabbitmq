# 🐰 NXH RabbitMQ - Custom Docker Image

[![Build Status](https://github.com/alexNXH/nxh-rabbitmq/workflows/Build%20and%20Push%20Multi-Arch%20Docker%20Image/badge.svg)](https://github.com/alexNXH/nxh-rabbitmq/actions)
[![Docker Pulls](https://img.shields.io/docker/pulls/nexah/nxh-rabbitmq.svg)](https://hub.docker.com/r/nexah/nxh-rabbitmq)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Image Docker RabbitMQ personnalisée et optimisée pour les architectures **ARM64** et **AMD64**, prête pour le déploiement Kubernetes.

## 📋 Table des matières.

- [Caractéristiques](#-caractéristiques)
- [Prérequis](#-prérequis)
- [Installation rapide](#-installation-rapide)
- [Configuration](#-configuration)
- [Utilisation locale](#-utilisation-locale)
- [Build manuel](#-build-manuel)
- [CI/CD GitHub Actions](#-cicd-github-actions)
- [Déploiement Kubernetes](#-déploiement-kubernetes)
- [Sécurité](#-sécurité)
- [Troubleshooting](#-troubleshooting)

## ✨ Caractéristiques

- 🏗️ **Multi-architecture** : Support natif ARM64 et AMD64
- 🔐 **Sécurité renforcée** : Credentials personnalisables via variables d'environnement
- 📊 **Management UI** : Interface web préinstallée (port 15672)
- 📈 **Monitoring** : Plugin Prometheus activé
- 🚀 **Optimisé** : Image Alpine Linux pour une taille minimale
- ♻️ **Production-ready** : Healthchecks configurés
- 🔌 **Plugins activés** :
  - `rabbitmq_management`
  - `rabbitmq_prometheus`
  - `rabbitmq_shovel`
  - `rabbitmq_shovel_management`

## 🔧 Prérequis

### Pour l'utilisation
- Docker 20.10+
- Docker Compose 2.0+ (optionnel)

### Pour le développement
- Docker avec support Buildx
- Git
- Compte DockerHub (pour la CI/CD)

## 🚀 Installation rapide

### Avec Docker Hub (recommandé)

```bash
docker pull YOUR_USERNAME/nxh-rabbitmq:latest
docker run -d \
  --name nxh-rabbitmq \
  -p 5672:5672 \
  -p 15672:15672 \
  -e NXH_RABBITMQ_DEFAULT_USER=admin \
  -e NXH_RABBITMQ_DEFAULT_PASS=votre_mot_de_passe_securise \
  YOUR_USERNAME/nxh-rabbitmq:latest
```

### Avec docker-compose

```bash
git clone https://github.com/YOUR_USERNAME/nxh-rabbitmq.git
cd nxh-rabbitmq
docker-compose up -d
```

Accédez à l'interface web : **http://localhost:15672**
- Username: `nxh_admin`
- Password: `nxh_secure_password_2024`

## ⚙️ Configuration

### Variables d'environnement

| Variable | Description | Défaut |
|----------|-------------|--------|
| `NXH_RABBITMQ_DEFAULT_USER` | Nom d'utilisateur admin | `nxh_admin` |
| `NXH_RABBITMQ_DEFAULT_PASS` | Mot de passe admin | `nxh_secure_password_2024` |
| `RABBITMQ_VM_MEMORY_HIGH_WATERMARK` | Seuil mémoire (0.6 = 60%) | `0.6` |
| `RABBITMQ_DISK_FREE_LIMIT` | Espace disque minimum | `2GB` |

### Override des credentials

#### Méthode 1 : Fichier .env (recommandé pour local)

Créez un fichier `.env` à la racine :

```env
NXH_RABBITMQ_DEFAULT_USER=mon_user
NXH_RABBITMQ_DEFAULT_PASS=mon_super_mot_de_passe
```

Puis lancez :

```bash
docker-compose up -d
```

#### Méthode 2 : Variables d'environnement inline

```bash
docker run -d \
  -e NXH_RABBITMQ_DEFAULT_USER=custom_user \
  -e NXH_RABBITMQ_DEFAULT_PASS=custom_password \
  -p 5672:5672 -p 15672:15672 \
  YOUR_USERNAME/nxh-rabbitmq:latest
```

## 💻 Utilisation locale

### Test rapide

```bash
# 1. Clone du projet
git clone https://github.com/YOUR_USERNAME/nxh-rabbitmq.git
cd nxh-rabbitmq

# 2. Lancement
docker-compose up -d

# 3. Vérification des logs
docker-compose logs -f rabbitmq

# 4. Test de connexion
curl -u nxh_admin:nxh_secure_password_2024 http://localhost:15672/api/overview

# 5. Arrêt
docker-compose down
```

### Avec persistance des données

```bash
# Les données sont automatiquement persistées dans le volume 'rabbitmq_data'
docker-compose up -d

# Pour supprimer les données
docker-compose down -v
```

## 🏗️ Build manuel

### Build simple (architecture locale)

```bash
docker build -t nxh-rabbitmq:local .
```

### Build multi-architecture (ARM64 + AMD64)

#### 1. Activer Buildx

```bash
docker buildx create --name multiarch --use
docker buildx inspect --bootstrap
```

#### 2. Build pour ARM64 uniquement

```bash
docker buildx build \
  --platform linux/arm64 \
  -t nxh-rabbitmq:arm64 \
  --load \
  .
```

#### 3. Build pour AMD64 uniquement

```bash
docker buildx build \
  --platform linux/amd64 \
  -t nxh-rabbitmq:amd64 \
  --load \
  .
```

#### 4. Build et push multi-arch vers DockerHub

```bash
docker login

docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t YOUR_USERNAME/nxh-rabbitmq:latest \
  -t YOUR_USERNAME/nxh-rabbitmq:v1.0.0 \
  --push \
  .
```

### Vérifier les architectures supportées

```bash
docker buildx imagetools inspect YOUR_USERNAME/nxh-rabbitmq:latest
```

## 🤖 CI/CD GitHub Actions

### Configuration des secrets GitHub

1. Allez dans **Settings → Secrets and variables → Actions**
2. Ajoutez ces secrets :

| Secret | Description |
|--------|-------------|
| `DOCKERHUB_USERNAME` | Votre nom d'utilisateur DockerHub |
| `DOCKERHUB_TOKEN` | Token d'accès DockerHub (pas le mot de passe) |

### Générer un token DockerHub

```bash
# Allez sur https://hub.docker.com/settings/security
# Cliquez sur "New Access Token"
# Copiez le token généré
```

### Déclenchement automatique

Le workflow se déclenche automatiquement sur :
- ✅ Push sur `main` ou `develop`
- ✅ Création de tag `v*` (ex: v1.0.0)
- ✅ Pull Request vers `main` ou `develop`
- ✅ Déclenchement manuel (workflow_dispatch)

### Tags générés automatiquement

| Condition | Tags créés |
|-----------|------------|
| Push sur `main` | `latest`, `main-abc1234` |
| Push sur `develop` | `develop`, `develop-abc1234` |
| Tag `v1.2.3` | `1.2.3`, `1.2`, `1`, `latest` |

### Vérifier le build

```bash
# Voir les logs dans GitHub Actions
# https://github.com/YOUR_USERNAME/nxh-rabbitmq/actions

# Vérifier sur DockerHub
docker pull YOUR_USERNAME/nxh-rabbitmq:latest
docker inspect YOUR_USERNAME/nxh-rabbitmq:latest | grep Architecture
```

## ☸️ Déploiement Kubernetes

### Déploiement simple

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nxh-rabbitmq
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nxh-rabbitmq
  template:
    metadata:
      labels:
        app: nxh-rabbitmq
    spec:
      containers:
      - name: rabbitmq
        image: YOUR_USERNAME/nxh-rabbitmq:latest
        ports:
        - containerPort: 5672
          name: amqp
        - containerPort: 15672
          name: management
        env:
        - name: NXH_RABBITMQ_DEFAULT_USER
          valueFrom:
            secretKeyRef:
              name: rabbitmq-secret
              key: username
        - name: NXH_RABBITMQ_DEFAULT_PASS
          valueFrom:
            secretKeyRef:
              name: rabbitmq-secret
              key: password
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "2"
        livenessProbe:
          exec:
            command:
            - rabbitmq-diagnostics
            - ping
          initialDelaySeconds: 60
          periodSeconds: 30
        readinessProbe:
          exec:
            command:
            - rabbitmq-diagnostics
            - check_running
          initialDelaySeconds: 20
          periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: nxh-rabbitmq
spec:
  selector:
    app: nxh-rabbitmq
  ports:
  - name: amqp
    port: 5672
    targetPort: 5672
  - name: management
    port: 15672
    targetPort: 15672
---
apiVersion: v1
kind: Secret
metadata:
  name: rabbitmq-secret
type: Opaque
stringData:
  username: "admin"
  password: "changeme_in_production"
```

### Déployer

```bash
kubectl apply -f k8s-deployment.yaml
kubectl get pods -l app=nxh-rabbitmq
kubectl logs -f deployment/nxh-rabbitmq
```

## 🔒 Sécurité

### ⚠️ Recommandations importantes

1. **Changez TOUJOURS les credentials par défaut en production**
2. **Utilisez des secrets Kubernetes** pour stocker les credentials
3. **Activez TLS** pour les connexions AMQP en production
4. **Limitez l'accès** à l'interface management (15672)
5. **Surveillez les logs** pour détecter les tentatives d'accès non autorisées

### Bonnes pratiques

```bash
# Générer un mot de passe fort
openssl rand -base64 32

# Utiliser des secrets Kubernetes
kubectl create secret generic rabbitmq-secret \
  --from-literal=username=admin \
  --from-literal=password=$(openssl rand -base64 32)
```

## 🔍 Troubleshooting

### Le container ne démarre pas

```bash
# Vérifier les logs
docker logs nxh-rabbitmq

# Vérifier les resources
docker stats nxh-rabbitmq
```

### Impossible de se connecter au Management UI

```bash
# Vérifier que le port est exposé
docker port nxh-rabbitmq

# Tester la connexion
curl -u nxh_admin:nxh_secure_password_2024 http://localhost:15672/api/overview
```

### Erreur de permissions

```bash
# L'image utilise l'utilisateur 'rabbitmq' non-root
# Vérifier les permissions du volume
docker exec nxh-rabbitmq ls -la /var/lib/rabbitmq
```

### Build multi-arch échoue

```bash
# Réinitialiser buildx
docker buildx rm multiarch
docker buildx create --name multiarch --use
docker buildx inspect --bootstrap
```

## 📚 Resources

- [Documentation officielle RabbitMQ](https://www.rabbitmq.com/documentation.html)
- [Docker Buildx](https://docs.docker.com/buildx/working-with-buildx/)
- [GitHub Actions](https://docs.github.com/en/actions)

## 📄 License

MIT License - voir le fichier [LICENSE](LICENSE)

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une issue ou une pull request.

---

**Maintenu par l'équipe DevOps NXH** 🚀
