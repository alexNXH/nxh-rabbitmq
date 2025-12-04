# NXH RabbitMQ Custom Service

![Docker Build](https://github.com/nexah/nxh-rabbitmq/workflows/Build%20and%20Push%20Docker%20Image/badge.svg)
![Multi-Arch](https://img.shields.io/badge/architecture-amd64%20%7C%20arm64-success)
<!-- ![License](https://img.shields.io/badge/license-MIT-blue) -->

Service RabbitMQ custom optimisé pour les environnements ARM64 et prêt pour le déploiement Kubernetes.

## 📋 Fonctionnalités

- ✅ Support multi-architecture (ARM64/AMD64)
- ✅ Configuration optimisée pour Kubernetes
- ✅ Variables d'environnement customisables
- ✅ Management UI intégrée
- ✅ Définitions automatiques (utilisateurs, vhosts, permissions)
- ✅ Health checks intégrés
- ✅ Logging structuré
- ✅ Sécurité renforcée
- ✅ Persistence des données

## 🚀 Démarrage Rapide.

### Prérequis

- Docker 20.10+
- Docker Compose 2.0+
- (Optionnel) Kubernetes 1.24+

### 1. Cloner le repository

```bash
git clone https://github.com/your-org/nxh-rabbitmq.git
cd nxh-rabbitmq