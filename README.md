# 🛒 NexusCommerce Microservices Platform

<div align="center">

![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)
![ArgoCD](https://img.shields.io/badge/ArgoCD-EF7B4D?style=for-the-badge&logo=argo&logoColor=white)
![Istio](https://img.shields.io/badge/Istio-466BB0?style=for-the-badge&logo=istio&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-%234ea94b.svg?style=for-the-badge&logo=mongodb&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/postgres-%23316192.svg?style=for-the-badge&logo=postgresql&logoColor=white)
![Apache Kafka](https://img.shields.io/badge/Apache%20Kafka-000?style=for-the-badge&logo=apachekafka)
![Redis](https://img.shields.io/badge/redis-%23DD0031.svg?style=for-the-badge&logo=redis&logoColor=white)
![Elastic](https://img.shields.io/badge/-ElasticSearch-005571?style=for-the-badge&logo=elasticsearch)

**A cloud-native, scalable e-commerce microservices platform built with GitOps principles**

[🚀 Quick Start](#-quick-start) • [📖 Documentation](#-documentation) • [🏗️ Architecture](#️-architecture) • [🔧 Configuration](#-configuration)

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture](#️-architecture)
- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Project Structure](#-project-structure)
- [Services](#-services)
- [Infrastructure](#-infrastructure)
- [Monitoring & Observability](#-monitoring--observability)
- [Development](#-development)
- [Production Deployment](#-production-deployment)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🌟 Overview

NexusCommerce is a modern, cloud-native e-commerce platform built using microservices architecture and deployed with GitOps principles using ArgoCD. The platform demonstrates best practices for building scalable, resilient, and observable distributed systems.

### 🎯 Key Highlights

- **🔄 GitOps Workflow**: Fully automated deployments with ArgoCD
- **🕸️ Service Mesh**: Traffic management with Istio
- **📊 Observability**: Complete monitoring stack (ELK, Prometheus, Grafana, Zipkin)
- **🔒 Security**: mTLS, RBAC, and security policies
- **🌍 Multi-Environment**: Dev, Staging, and Production configurations
- **📈 Scalable**: Horizontal pod autoscaling and load balancing

---

## 🏗️ Architecture

### System Architecture

```mermaid
graph TB
    subgraph "Client Layer"
        WEB[Web Frontend]
        MOBILE[Mobile App]
        API_CLIENT[API Clients]
    end

    subgraph "Ingress & Gateway"
        NGINX[NGINX Ingress]
        ISTIO_GW[Istio Gateway]
        API_GW[API Gateway]
    end

    subgraph "Microservices Layer"
        USER[User Service]
        PRODUCT[Product Service]
        CART[Cart Service]
        ORDER[Order Service]
        PAYMENT[Payment Service]
        SHIPPING[Shipping Service]
        LOYALTY[Loyalty Service]
        NOTIFICATION[Notification Service]
    end

    subgraph "Infrastructure Services"
        EUREKA[Service Discovery]
        CONFIG[Config Server]
        ZIPKIN[Distributed Tracing]
    end

    subgraph "Data Layer"
        MONGO[(MongoDB)]
        POSTGRES[(PostgreSQL)]
        REDIS[(Redis Cache)]
        KAFKA[Apache Kafka]
        ZOOKEEPER[Zookeeper]
    end

    subgraph "Observability Stack"
        ELASTICSEARCH[(Elasticsearch)]
        LOGSTASH[Logstash]
        KIBANA[Kibana]
        PROMETHEUS[Prometheus]
        GRAFANA[Grafana]
        KIALI[Kiali]
    end

    WEB --> NGINX
    MOBILE --> NGINX
    API_CLIENT --> NGINX
    
    NGINX --> ISTIO_GW
    ISTIO_GW --> API_GW
    
    API_GW --> USER
    API_GW --> PRODUCT
    API_GW --> CART
    API_GW --> ORDER
    API_GW --> PAYMENT
    API_GW --> SHIPPING
    API_GW --> LOYALTY
    API_GW --> NOTIFICATION
    
    USER --> EUREKA
    PRODUCT --> EUREKA
    CART --> EUREKA
    ORDER --> EUREKA
    
    USER --> CONFIG
    PRODUCT --> CONFIG
    CART --> CONFIG
    
    USER --> MONGO
    CART --> MONGO
    PRODUCT --> POSTGRES
    ORDER --> POSTGRES
    PAYMENT --> POSTGRES
    SHIPPING --> POSTGRES
    LOYALTY --> POSTGRES
    
    CART --> REDIS
    USER --> REDIS
    
    ORDER --> KAFKA
    PAYMENT --> KAFKA
    NOTIFICATION --> KAFKA
    
    USER --> ZIPKIN
    PRODUCT --> ZIPKIN
    ORDER --> ZIPKIN
    
    LOGSTASH --> ELASTICSEARCH
    KIBANA --> ELASTICSEARCH
    PROMETHEUS --> GRAFANA
    KIALI --> PROMETHEUS
```

### GitOps Deployment Flow

```mermaid
graph LR
    subgraph "Development"
        DEV[Developer]
        GIT[Git Repository]
    end
    
    subgraph "CI/CD Pipeline"
        BUILD[Build & Test]
        IMAGE[Container Images]
        MANIFEST[Update Manifests]
    end
    
    subgraph "GitOps"
        ARGOCD[ArgoCD]
        REPO[Config Repository]
    end
    
    subgraph "Kubernetes Cluster"
        DEV_NS[Development]
        STAGING_NS[Staging]
        PROD_NS[Production]
    end
    
    DEV --> GIT
    GIT --> BUILD
    BUILD --> IMAGE
    IMAGE --> MANIFEST
    MANIFEST --> REPO
    
    ARGOCD --> REPO
    ARGOCD --> DEV_NS
    ARGOCD --> STAGING_NS
    ARGOCD --> PROD_NS
    
    REPO -.-> ARGOCD
```

### Service Mesh Architecture

```mermaid
graph TB
    subgraph "Istio Service Mesh"
        subgraph "Control Plane"
            ISTIOD[Istiod]
            PILOT[Pilot]
            CITADEL[Citadel]
        end
        
        subgraph "Data Plane"
            subgraph "Microservices Namespace"
                USER_POD[User Service + Envoy]
                PRODUCT_POD[Product Service + Envoy]
                ORDER_POD[Order Service + Envoy]
                PAYMENT_POD[Payment Service + Envoy]
            end
            
            subgraph "Infrastructure Namespace"
                API_GW_POD[API Gateway + Envoy]
                CONFIG_POD[Config Server + Envoy]
            end
        end
        
        subgraph "Ingress Gateway"
            ISTIO_INGRESS[Istio Ingress Gateway]
        end
    end
    
    ISTIOD --> USER_POD
    ISTIOD --> PRODUCT_POD
    ISTIOD --> ORDER_POD
    ISTIOD --> PAYMENT_POD
    ISTIOD --> API_GW_POD
    ISTIOD --> CONFIG_POD
    
    ISTIO_INGRESS --> API_GW_POD
    API_GW_POD --> USER_POD
    API_GW_POD --> PRODUCT_POD
    USER_POD --> ORDER_POD
    ORDER_POD --> PAYMENT_POD
```

---

## ✨ Features

### 🔧 Core Platform Features
- **Microservices Architecture**: Domain-driven service decomposition
- **Event-Driven Communication**: Asynchronous messaging with Apache Kafka
- **Database per Service**: Polyglot persistence (MongoDB, PostgreSQL, Redis)
- **API Gateway Pattern**: Centralized request routing and cross-cutting concerns
- **Service Discovery**: Automatic service registration and discovery with Eureka

### 🚀 DevOps & GitOps
- **GitOps Deployment**: Declarative, version-controlled deployments
- **Multi-Environment Support**: Separate configurations for dev/staging/prod
- **Automated Rollbacks**: Instant rollback capabilities with ArgoCD
- **Progressive Delivery**: Canary deployments and blue-green strategies

### 🔒 Security & Compliance
- **mTLS**: Mutual TLS for service-to-service communication
- **RBAC**: Role-based access control
- **Network Policies**: Kubernetes network segmentation
- **Secret Management**: Encrypted secrets with Kubernetes

### 📊 Observability & Monitoring
- **Distributed Tracing**: Request flow tracking with Zipkin
- **Centralized Logging**: ELK stack for log aggregation
- **Metrics & Alerting**: Prometheus and Grafana
- **Service Mesh Observability**: Kiali for traffic visualization

### 🔄 Resilience & Scalability
- **Circuit Breakers**: Fault tolerance with Resilience4j
- **Load Balancing**: Intelligent traffic distribution
- **Auto-scaling**: HPA and VPA for dynamic scaling
- **Health Checks**: Comprehensive health monitoring

---

## 📋 Prerequisites

### Required Tools
```bash
# Container & Kubernetes
docker >= 20.10
kubectl >= 1.24
helm >= 3.8

# GitOps
argocd >= 2.6

# Development (Optional)
k3d >= 5.4  # For local development
kustomize >= 4.5
```

### Kubernetes Cluster Requirements
- **Kubernetes Version**: 1.24+
- **Minimum Resources**: 8 CPU cores, 16GB RAM
- **Storage Classes**: Default storage class configured
- **LoadBalancer**: MetalLB, cloud provider LB, or NodePort for development

---

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/your-org/nexus-commerce-gitops.git
cd nexus-commerce-gitops
```

### 2. Install ArgoCD
```bash
# Create ArgoCD namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Access ArgoCD UI (get password)
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 3. Deploy the Platform
```bash
# Deploy the App of Apps pattern
kubectl apply -f argocd/applications/app-of-apps.yaml

# Monitor deployment status
kubectl get applications -n argocd -w
```

### 4. Access the Services

#### Development Environment
```bash
# Port forward to access services locally
kubectl port-forward svc/api-gateway 8099:8099 -n infrastructure
kubectl port-forward svc/kibana 5601:5601 -n observability
kubectl port-forward svc/kiali 20001:20001 -n observability
```

#### Service URLs (with ingress configured)
- **API Gateway**: http://api.nexus-commerce.local
- **Kibana**: http://kibana.nexus-commerce.local
- **Kiali**: http://kiali.nexus-commerce.local
- **Kafka UI**: http://kafka-ui.nexus-commerce.local
- **ArgoCD**: http://argocd.nexus-commerce.local

---

## 📁 Project Structure

```
nexus-commerce-gitops/
├── argocd/                           # ArgoCD Applications
│   ├── applications/                 # Application definitions
│   │   ├── app-of-apps.yaml         # Root application
│   │   ├── data-layer.yaml          # Data services
│   │   ├── infrastructure.yaml      # Infrastructure services
│   │   ├── microservices.yaml       # Business microservices
│   │   ├── observability.yaml       # Monitoring stack
│   │   └── istio.yaml               # Service mesh
│   └── bootstrap/                    # Bootstrap configurations
│
├── base/                            # Base Kubernetes manifests
│   ├── data/                        # Data layer services
│   │   ├── mongodb/                 # MongoDB clusters
│   │   ├── postgresql/              # PostgreSQL databases
│   │   ├── redis/                   # Redis cache
│   │   ├── kafka/                   # Apache Kafka
│   │   └── zookeeper/               # Zookeeper
│   │
│   ├── infrastructure/              # Infrastructure services
│   │   ├── api-gateway/             # API Gateway
│   │   ├── config-server/           # Configuration service
│   │   ├── eureka-server/           # Service discovery
│   │   ├── ingress-nginx/           # Ingress controller
│   │   └── istio/                   # Service mesh
│   │
│   ├── microservices/               # Business microservices
│   │   ├── user-service/            # User management
│   │   ├── product-service/         # Product catalog
│   │   ├── cart-service/            # Shopping cart
│   │   ├── order-service/           # Order processing
│   │   ├── payment-service/         # Payment processing
│   │   ├── shipping-service/        # Shipping & logistics
│   │   ├── loyalty-service/         # Loyalty program
│   │   └── notification-service/    # Notifications
│   │
│   └── observability/               # Monitoring & observability
│       ├── elk/                     # Elasticsearch, Logstash, Kibana
│       └── kiali/                   # Service mesh observability
│
├── environments/                    # Environment-specific configurations
│   ├── dev/                        # Development environment
│   ├── staging/                     # Staging environment
│   └── production/                  # Production environment
│
├── tools/                          # Additional tools
│   ├── kafka-ui/                   # Kafka management UI
│   └── zipkin-server/              # Distributed tracing
│
└── docs/                           # Documentation
    ├── architecture/               # Architecture diagrams
    ├── deployment/                 # Deployment guides
    └── troubleshooting/            # Troubleshooting guides
```

---

## 🔧 Services

### 💼 Business Microservices

| Service | Port | Database | Description |
|---------|------|----------|-------------|
| **User Service** | 8081 | MongoDB | User management, authentication, profiles |
| **Product Service** | 8082 | PostgreSQL | Product catalog, inventory management |
| **Cart Service** | 8082 | MongoDB + Redis | Shopping cart, session management |
| **Order Service** | 8082 | PostgreSQL | Order processing, order history |
| **Payment Service** | 8084 | PostgreSQL | Payment processing, billing |
| **Shipping Service** | 8085 | PostgreSQL | Shipping, tracking, logistics |
| **Loyalty Service** | 8084 | PostgreSQL | Loyalty programs, rewards |
| **Notification Service** | 8086 | MongoDB | Email, SMS, push notifications |

### 🏗️ Infrastructure Services

| Service | Port | Description |
|---------|------|-------------|
| **API Gateway** | 8099 | Request routing, rate limiting, authentication |
| **Config Server** | 8888 | Centralized configuration management |
| **Eureka Server** | 8761 | Service discovery and registration |
| **Zipkin Server** | 9411 | Distributed tracing |

---

## 🗄️ Infrastructure

### Data Layer

```mermaid
graph TB
    subgraph "Data Persistence"
        subgraph "MongoDB Clusters"
            USER_MONGO[(User MongoDB)]
            CART_MONGO[(Cart MongoDB)]
            NOTIFICATION_MONGO[(Notification MongoDB)]
        end
        
        subgraph "PostgreSQL Databases"
            PRODUCT_PG[(Product PostgreSQL)]
            ORDER_PG[(Order PostgreSQL)]
            PAYMENT_PG[(Payment PostgreSQL)]
            SHIPPING_PG[(Shipping PostgreSQL)]
            LOYALTY_PG[(Loyalty PostgreSQL)]
        end
        
        subgraph "Caching Layer"
            REDIS[(Redis Cluster)]
        end
        
        subgraph "Message Broker"
            KAFKA[Apache Kafka]
            ZOOKEEPER[Zookeeper]
        end
    end
    
    subgraph "Services"
        USER_SVC[User Service]
        CART_SVC[Cart Service]
        PRODUCT_SVC[Product Service]
        ORDER_SVC[Order Service]
        PAYMENT_SVC[Payment Service]
        SHIPPING_SVC[Shipping Service]
        LOYALTY_SVC[Loyalty Service]
        NOTIFICATION_SVC[Notification Service]
    end
    
    USER_SVC --> USER_MONGO
    CART_SVC --> CART_MONGO
    CART_SVC --> REDIS
    PRODUCT_SVC --> PRODUCT_PG
    ORDER_SVC --> ORDER_PG
    PAYMENT_SVC --> PAYMENT_PG
    SHIPPING_SVC --> SHIPPING_PG
    LOYALTY_SVC --> LOYALTY_PG
    NOTIFICATION_SVC --> NOTIFICATION_MONGO
    
    ORDER_SVC --> KAFKA
    PAYMENT_SVC --> KAFKA
    NOTIFICATION_SVC --> KAFKA
    KAFKA --> ZOOKEEPER
```

### Service Mesh Configuration

| Component | Version | Purpose |
|-----------|---------|---------|
| **Istio** | 1.20.0 | Service mesh, traffic management |
| **Envoy** | Bundled | Sidecar proxy, load balancing |
| **Kiali** | v1.76 | Service mesh observability |

---

## 📊 Monitoring & Observability

### Observability Stack

```mermaid
graph TB
    subgraph "Applications"
        APP1[User Service]
        APP2[Product Service]
        APP3[Order Service]
    end
    
    subgraph "Data Collection"
        FILEBEAT[Filebeat]
        PROMETHEUS[Prometheus]
        JAEGER[Zipkin]
    end
    
    subgraph "Data Processing"
        LOGSTASH[Logstash]
        ALERTMANAGER[Alertmanager]
    end
    
    subgraph "Storage"
        ELASTICSEARCH[(Elasticsearch)]
        PROMETHEUS_DB[(Prometheus DB)]
        ZIPKIN_DB[(Zipkin Storage)]
    end
    
    subgraph "Visualization"
        KIBANA[Kibana]
        GRAFANA[Grafana]
        KIALI[Kiali]
    end
    
    APP1 --> FILEBEAT
    APP2 --> FILEBEAT
    APP3 --> FILEBEAT
    
    APP1 --> PROMETHEUS
    APP2 --> PROMETHEUS
    APP3 --> PROMETHEUS
    
    APP1 --> JAEGER
    APP2 --> JAEGER
    APP3 --> JAEGER
    
    FILEBEAT --> LOGSTASH
    LOGSTASH --> ELASTICSEARCH
    ELASTICSEARCH --> KIBANA
    
    PROMETHEUS --> PROMETHEUS_DB
    PROMETHEUS --> ALERTMANAGER
    PROMETHEUS_DB --> GRAFANA
    
    JAEGER --> ZIPKIN_DB
    ZIPKIN_DB --> GRAFANA
    
    PROMETHEUS --> KIALI
```

### Monitoring Endpoints

| Service | Metrics | Logs | Traces |
|---------|---------|------|--------|
| **Kibana** | http://kibana.nexus-commerce.local | ✅ | ❌ |
| **Grafana** | http://grafana.nexus-commerce.local | ✅ | ✅ |
| **Kiali** | http://kiali.nexus-commerce.local | ✅ | ✅ |
| **Zipkin** | http://zipkin.nexus-commerce.local | ❌ | ✅ |

---

## 🔧 Configuration

### Environment Configuration

Each environment has its own overlay configuration:

#### Development Environment
```yaml
# environments/dev/kustomization.yaml
resources:
  - ../../base
  
patchesStrategicMerge:
  - replica-patch.yaml
  - resource-patch.yaml
  
configMapGenerator:
  - name: env-config
    literals:
      - ENVIRONMENT=development
      - LOG_LEVEL=DEBUG
```

#### Production Environment
```yaml
# environments/production/kustomization.yaml
resources:
  - ../../base
  
patchesStrategicMerge:
  - security-patch.yaml
  - scaling-patch.yaml
  
configMapGenerator:
  - name: env-config
    literals:
      - ENVIRONMENT=production
      - LOG_LEVEL=INFO
```

### ArgoCD Application Sync Waves

| Wave | Components | Purpose |
|------|------------|---------|
| **0** | Istio Base, Namespaces | Foundation |
| **1** | Istio Control Plane | Service Mesh |
| **2** | Data Layer | Databases, Message Brokers |
| **3** | Infrastructure | Config, Discovery, Gateway |
| **4** | Microservices | Business Logic |
| **5** | Observability | Monitoring Stack |

---

## 🛠️ Development

### Local Development Setup

1. **Create Local Kubernetes Cluster**
```bash
# Using k3d
k3d cluster create nexus-commerce \
  --port "80:80@loadbalancer" \
  --port "443:443@loadbalancer" \
  --k3s-arg "--disable=traefik@server:*"

# Using kind
kind create cluster --config=kind-config.yaml
```

2. **Install Development Tools**
```bash
# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Install Istio
istioctl install --set values.defaultRevision=default -y
kubectl label namespace default istio-injection=enabled
```

3. **Deploy Development Environment**
```bash
# Deploy via ArgoCD
kubectl apply -f argocd/applications/app-of-apps.yaml

# Or deploy directly with Kustomize
kubectl apply -k environments/dev/
```

### Testing

```bash
# Port forward services for testing
kubectl port-forward svc/api-gateway 8099:8099 -n infrastructure

# Test API endpoints
curl http://localhost:8099/api/users/health
curl http://localhost:8099/api/products/health
curl http://localhost:8099/api/orders/health
```

### Debugging

```bash
# Check ArgoCD application status
kubectl get applications -n argocd

# View application details
argocd app get nexus-commerce-app-of-apps

# Check pod logs
kubectl logs -f deployment/user-service -n microservices

# Access service mesh dashboard
kubectl port-forward svc/kiali 20001:20001 -n observability
```

---

## 🚀 Production Deployment

### Pre-deployment Checklist

- [ ] **Infrastructure Ready**: Kubernetes cluster with sufficient resources
- [ ] **Ingress Configured**: Load balancer or ingress controller setup
- [ ] **TLS Certificates**: SSL certificates for HTTPS
- [ ] **Secrets Management**: All secrets properly configured
- [ ] **Monitoring**: Observability stack functional
- [ ] **Backup Strategy**: Database backup procedures in place

### Deployment Steps

1. **Prepare Production Environment**
```bash
# Apply production-specific configurations
kubectl apply -k environments/production/
```

2. **Deploy via ArgoCD**
```bash
# Create production ArgoCD application
kubectl apply -f argocd/applications/production/app-of-apps.yaml
```

3. **Verify Deployment**
```bash
# Check all applications are synced
argocd app list

# Verify all pods are running
kubectl get pods --all-namespaces
```

4. **Run Health Checks**
```bash
# Check service health
curl https://api.nexus-commerce.com/health

# Verify monitoring
curl https://grafana.nexus-commerce.com/api/health
```

### Production Considerations

#### Security
- Enable Pod Security Standards
- Configure Network Policies
- Implement proper RBAC
- Enable audit logging
- Use private container registries

#### Monitoring & Alerting
- Configure alerts for critical metrics
- Set up log retention policies
- Monitor resource utilization
- Track application performance

#### Backup & Disaster Recovery
- Automated database backups
- Cross-region data replication
- Disaster recovery procedures
- Regular backup testing

---

## 🤝 Contributing

### Development Workflow

1. **Fork and Clone**
2. **Create Feature Branch**
```bash
git checkout -b feature/new-service
```

3. **Make Changes**
- Update Kubernetes manifests
- Test in development environment
- Update documentation

4. **Submit Pull Request**
- Ensure all tests pass
- Update relevant documentation
- Follow commit message conventions

### Code Standards

- **Kubernetes Manifests**: Follow Kubernetes best practices
- **Documentation**: Update README and inline comments
- **Testing**: Include integration tests for new services
- **Security**: Follow security guidelines

### Testing Guidelines

```bash
# Lint Kubernetes manifests
kubectl apply --dry-run=client -k environments/dev/

# Validate with kubeval
kubeval base/**/*.yaml

# Security scanning
kube-score score base/**/*.yaml
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🆘 Support

### Documentation
- [Architecture Guide](docs/architecture/)
- [Deployment Guide](docs/deployment/)
- [Troubleshooting](docs/troubleshooting/)

### Community
- **Issues**: [GitHub Issues](https://github.com/your-org/nexus-commerce-gitops/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/nexus-commerce-gitops/discussions)
- **Wiki**: [Project Wiki](https://github.com/your-org/nexus-commerce-gitops/wiki)

### Contact
- **Email**: devops@nexuscommerce.com
- **Slack**: [#nexus-commerce-dev](https://nexuscommerce.slack.com)

---

<div align="center">

**⭐ If you find this project helpful, please give it a star! ⭐**

Made with ❤️ by the NexusCommerce Team

</div>
