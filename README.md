# 🚀 Nexus Commerce - GitOps Repository with ArgoCD

<div align="center">

![ArgoCD](https://img.shields.io/badge/ArgoCD-EF7B4D?style=for-the-badge&logo=argo&logoColor=white)
![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)
![Kustomize](https://img.shields.io/badge/Kustomize-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![GitOps](https://img.shields.io/badge/GitOps-100000?style=for-the-badge&logo=git&logoColor=white)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.28+-blue.svg)](https://kubernetes.io/)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-2.8+-orange.svg)](https://argoproj.github.io/cd/)
[![Kustomize](https://img.shields.io/badge/Kustomize-5.0+-green.svg)](https://kustomize.io/)

*Declarative GitOps deployment for Nexus Commerce microservices platform*

</div>

## 📋 Table of Contents

- [Overview](#-overview)
- [GitOps Architecture](#-gitops-architecture)
- [Repository Structure](#-repository-structure)
- [ArgoCD Applications](#-argocd-applications)
- [Quick Start](#-quick-start)
- [Deployment Layers](#-deployment-layers)
- [Environment Management](#-environment-management)
- [Monitoring & Health Checks](#-monitoring--health-checks)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)

## 🎯 Overview

**Nexus Commerce GitOps Repository** is the single source of truth for deploying our cloud-native e-commerce microservices platform using **ArgoCD** and **GitOps** principles. This repository contains all Kubernetes manifests, configurations, and deployment automation for multiple environments.

### 🌟 Key Features

- **🔄 GitOps Workflow**: Automated deployments triggered by Git commits
- **🏗️ App of Apps Pattern**: Hierarchical application management with ArgoCD
- **📦 Kustomize Integration**: Environment-specific configuration overlays
- **🔧 Multi-Environment Support**: Dev, Staging, Production configurations
- **🚀 Auto-Sync & Self-Healing**: Automated drift detection and correction
- **📊 Declarative Infrastructure**: Complete infrastructure as code
- **🔒 Security & Compliance**: RBAC, secrets management, and audit trails

## 🏗️ GitOps Architecture

### High-Level GitOps Flow

```mermaid
graph TB
    subgraph "Development Workflow"
        DEV[👨‍💻 Developer] --> COMMIT[📝 Git Commit]
        COMMIT --> PUSH[⬆️ Git Push]
        PUSH --> REPO[📁 GitOps Repository]
    end
    
    subgraph "ArgoCD GitOps Engine"
        REPO --> ARGOCD[🔄 ArgoCD Controller]
        ARGOCD --> SYNC[🔄 Auto-Sync]
        SYNC --> COMPARE[🔍 State Comparison]
        COMPARE --> DEPLOY[🚀 Deploy Changes]
    end
    
    subgraph "Kubernetes Infrastructure"
        DEPLOY --> K8S[☸️ Kubernetes Cluster]
        K8S --> APPS[🎯 Applications]
        APPS --> SERVICES[🔧 Microservices]
        SERVICES --> INFRA[🏗️ Infrastructure]
    end
    
    subgraph "Monitoring & Feedback"
        K8S --> HEALTH[💊 Health Checks]
        HEALTH --> ALERTS[🚨 Alerts]
        ALERTS --> DASHBOARDS[📊 Dashboards]
        DASHBOARDS --> DEV
    end

    style ARGOCD fill:#ef7b4d,color:#fff
    style K8S fill:#326ce5,color:#fff
    style REPO fill:#28a745,color:#fff
    style DEPLOY fill:#fd7e14,color:#fff
```

### ArgoCD App of Apps Architecture

```mermaid
graph TB
    subgraph "ArgoCD Management"
        ROOT[🎯 App of Apps<br/>nexus-commerce-app-of-apps]
        ROOT --> INFRA_APP[🏗️ Infrastructure App<br/>nexus-infrastructure]
        ROOT --> MICRO_APP[🔧 Microservices App<br/>nexus-microservices]
        ROOT --> DATA_APP[💾 Data Layer App<br/>nexus-data-layer]
        ROOT --> OBS_APP[📊 Observability App<br/>nexus-observability]
        ROOT --> INGRESS_APP[🌐 Ingress App<br/>nexus-ingress]
    end
    
    subgraph "Infrastructure Layer"
        INFRA_APP --> CONFIG[⚙️ Config Server<br/>Port: 8888]
        INFRA_APP --> EUREKA[🗺️ Eureka Server<br/>Port: 8761]
        INFRA_APP --> GATEWAY[🌐 API Gateway<br/>Port: 8099]
    end
    
    subgraph "Microservices Layer"
        MICRO_APP --> USER[👤 User Service<br/>Port: 8080]
        MICRO_APP --> PRODUCT[📦 Product Service<br/>Port: 8081]
        MICRO_APP --> CART[🛒 Cart Service<br/>Port: 8082]
        MICRO_APP --> ORDER[📋 Order Service<br/>Port: 8083]
    end
    
    subgraph "Data Layer"
        DATA_APP --> POSTGRES[🐘 PostgreSQL<br/>Port: 5432]
        DATA_APP --> REDIS[🔴 Redis<br/>Port: 6379]
        DATA_APP --> KAFKA[📡 Apache Kafka<br/>Port: 9092]
    end
    
    subgraph "Ingress & Networking"
        INGRESS_APP --> NGINX[🌐 NGINX Ingress<br/>Ports: 80/443]
        NGINX --> LB[⚖️ Load Balancer]
    end
    
    subgraph "Observability Stack"
        OBS_APP --> PROMETHEUS[📈 Prometheus<br/>Port: 9090]
        OBS_APP --> GRAFANA[📊 Grafana<br/>Port: 3000]
        OBS_APP --> ZIPKIN[🔍 Zipkin<br/>Port: 9411]
    end

    style ROOT fill:#e1f5fe,stroke:#01579b,stroke-width:3px
    style INFRA_APP fill:#fff3e0,stroke:#e65100,stroke-width:2px
    style MICRO_APP fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    style DATA_APP fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px
    style OBS_APP fill:#fce4ec,stroke:#880e4f,stroke-width:2px
    style INGRESS_APP fill:#f1f8e9,stroke:#33691e,stroke-width:2px
```

## 📁 Repository Structure

```
gitops-repo_ArgoCD/
│
├── 📁 argocd/                          # ArgoCD application definitions
│   ├── 📁 applications/                # App of Apps pattern
│   │   ├── app-of-apps.yaml           # Root application
│   │   ├── infrastructure.yaml        # Infrastructure apps
│   │   ├── microservices.yaml         # Microservices apps
│   │   ├── data-layer.yaml            # Data layer apps
│   │   └── observability.yaml         # Monitoring apps
│   └── 📁 bootstrap/                   # ArgoCD bootstrap configs
│
├── 📁 base/                            # Base Kustomize configurations
│   ├── 📁 infrastructure/             # Core infrastructure services
│   │   ├── 📁 api-gateway/            # API Gateway configs
│   │   ├── 📁 config-server/          # Config Server configs
│   │   ├── 📁 eureka-server/          # Service Discovery configs
│   │   └── 📁 ingress-nginx/          # Ingress Controller configs
│   ├── 📁 microservices/              # Microservices base configs
│   │   ├── 📁 user-service/           # User management service
│   │   └── 📁 product-service/        # Product catalog service
│   ├── 📁 data/                       # Data layer services
│   └── 📁 observability/              # Monitoring & logging
│
├── 📁 environments/                    # Environment-specific overlays
│   ├── 📁 dev/                        # Development environment
│   │   ├── 📁 infrastructure/         # Dev infrastructure overlays
│   │   ├── 📁 microservices/          # Dev microservices overlays
│   │   ├── 📁 data/                   # Dev data layer configs
│   │   └── 📁 observability/          # Dev monitoring configs
│   ├── 📁 staging/                    # Staging environment
│   └── 📁 production/                 # Production environment
│
└── README.md                          # This file
```

### 🎯 Configuration Strategy

```mermaid
graph LR
    subgraph "Base Configuration"
        BASE[📦 Base Manifests<br/>Common configs]
    end
    
    subgraph "Environment Overlays"
        DEV[🛠️ Development<br/>• 1 replica<br/>• Debug logging<br/>• NodePort services]
        STAGING[🔧 Staging<br/>• 2 replicas<br/>• Info logging<br/>• LoadBalancer]
        PROD[🚀 Production<br/>• 3+ replicas<br/>• Error logging<br/>• High availability]
    end
    
    BASE --> DEV
    BASE --> STAGING
    BASE --> PROD
    
    style BASE fill:#e3f2fd,stroke:#1976d2
    style DEV fill:#f3e5f5,stroke:#7b1fa2
    style STAGING fill:#fff3e0,stroke:#f57c00
    style PROD fill:#e8f5e8,stroke:#388e3c
```

## 🎯 ArgoCD Applications

### App of Apps Pattern Implementation

```mermaid
graph TB
    subgraph "ArgoCD Application Hierarchy"
        ROOT[🎯 nexus-commerce-app-of-apps<br/>Namespace: argocd<br/>Path: argocd/applications]
        
        ROOT --> INFRA[🏗️ nexus-infrastructure<br/>Namespace: infrastructure<br/>Path: environments/dev/infrastructure]
        ROOT --> MICRO[🔧 nexus-microservices<br/>Namespace: microservices<br/>Path: environments/dev/microservices]
        ROOT --> DATA[💾 nexus-data-layer<br/>Namespace: data<br/>Path: environments/dev/data]
        ROOT --> OBS[📊 nexus-observability<br/>Namespace: observability<br/>Path: environments/dev/observability]
        ROOT --> INGRESS[🌐 nexus-ingress<br/>Namespace: ingress-nginx<br/>Path: base/infrastructure/ingress-nginx]
    end
    
    subgraph "Sync Policies"
        AUTO[🔄 Auto-Sync Enabled<br/>• Prune: true<br/>• Self-Heal: true]
        MANUAL[👋 Manual Sync<br/>• Data Layer<br/>• Production Only]
    end
    
    subgraph "Deployment Features"
        HEALTH[💊 Health Checks<br/>• Readiness Probes<br/>• Liveness Probes<br/>• Startup Probes]
        ROLLBACK[↩️ Auto Rollback<br/>• Failed deployments<br/>• Health check failures]
        SYNC_WAVES[🌊 Sync Waves<br/>• Infrastructure first<br/>• Dependencies managed]
    end
    
    INFRA -.-> AUTO
    MICRO -.-> AUTO
    OBS -.-> AUTO
    INGRESS -.-> AUTO
    DATA -.-> MANUAL
    
    AUTO --> HEALTH
    AUTO --> ROLLBACK
    AUTO --> SYNC_WAVES

    style ROOT fill:#e1f5fe,stroke:#01579b,stroke-width:3px
    style AUTO fill:#e8f5e8,stroke:#388e3c,stroke-width:2px
    style MANUAL fill:#fff3e0,stroke:#f57c00,stroke-width:2px
```

### Application Sync Strategy

| Application | Sync Policy | Prune | Self-Heal | Namespace | Notes |
|-------------|-------------|-------|-----------|-----------|--------|
| **App of Apps** | Auto | ✅ | ✅ | argocd | Root application manager |
| **Infrastructure** | Auto | ✅ | ✅ | infrastructure | Core services foundation |
| **Microservices** | Auto | ✅ | ✅ | microservices | Business logic services |
| **Ingress** | Auto | ✅ | ✅ | ingress-nginx | Traffic management |
| **Observability** | Auto | ✅ | ✅ | observability | Monitoring & alerting |
| **Data Layer** | Manual | ❌ | ❌ | data | Requires careful management |

## 🚀 Quick Start

### Prerequisites

![ArgoCD](https://img.shields.io/badge/ArgoCD-2.8+-EF7B4D?style=flat-square&logo=argo&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.28+-326CE5?style=flat-square&logo=kubernetes&logoColor=white)
![Kustomize](https://img.shields.io/badge/Kustomize-5.0+-6DB33F?style=flat-square&logo=kubernetes&logoColor=white)
![kubectl](https://img.shields.io/badge/kubectl-latest-326CE5?style=flat-square&logo=kubernetes&logoColor=white)

- Kubernetes cluster (v1.28+)
- ArgoCD installed and configured
- kubectl configured for your cluster
- Git repository access

### 1. 🏗️ Install ArgoCD (if not already installed)

```bash
# Create ArgoCD namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 2. 🔧 Access ArgoCD UI

```bash
# Port forward to access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Open browser to https://localhost:8080
# Username: admin
# Password: (from previous step)
```

### 3. 🚀 Deploy App of Apps

```bash
# Apply the root App of Apps application
kubectl apply -f argocd/applications/app-of-apps.yaml

# Verify the application is created
argocd app list
```

### 4. 📊 Monitor Deployment

```bash
# Watch ArgoCD applications
argocd app list

# Check application health
argocd app get nexus-commerce-app-of-apps

# View sync status
argocd app sync nexus-commerce-app-of-apps
```

## 🏗️ Deployment Layers

### Infrastructure Layer Deployment Flow

```mermaid
sequenceDiagram
    participant Dev as 👨‍💻 Developer
    participant Git as 📁 Git Repository
    participant ArgoCD as 🔄 ArgoCD
    participant K8s as ☸️ Kubernetes
    
    Dev->>Git: 1. Push infrastructure changes
    Note right of Git: environments/dev/infrastructure/
    
    Git->>ArgoCD: 2. Webhook triggers sync
    ArgoCD->>ArgoCD: 3. Detect configuration drift
    
    ArgoCD->>K8s: 4. Apply namespace
    Note right of K8s: Create 'infrastructure' namespace
    
    ArgoCD->>K8s: 5. Deploy Config Server
    Note right of K8s: External configuration management
    
    ArgoCD->>K8s: 6. Deploy Eureka Server
    Note right of K8s: Service discovery registry
    
    ArgoCD->>K8s: 7. Deploy API Gateway
    Note right of K8s: Traffic routing & security
    
    K8s->>ArgoCD: 8. Health check feedback
    ArgoCD->>Dev: 9. Deployment status
    
    Note over Dev,K8s: 🎯 Infrastructure Ready for Microservices
```

### Service Dependencies & Startup Order

```mermaid
graph TB
    subgraph "Startup Order & Dependencies"
        NAMESPACE[📁 Namespaces<br/>Wave: 0]
        
        CONFIG[⚙️ Config Server<br/>Wave: 1<br/>First to start]
        EUREKA[🗺️ Eureka Server<br/>Wave: 1<br/>Service Discovery]
        
        REDIS[🔴 Redis<br/>Wave: 2<br/>Caching Layer]
        POSTGRES[🐘 PostgreSQL<br/>Wave: 2<br/>Database]
        KAFKA[📡 Kafka<br/>Wave: 2<br/>Message Bus]
        
        GATEWAY[🌐 API Gateway<br/>Wave: 3<br/>Routing Layer]
        
        USER[👤 User Service<br/>Wave: 4]
        PRODUCT[📦 Product Service<br/>Wave: 4]
        
        INGRESS[🌐 Ingress<br/>Wave: 5<br/>External Access]
        
        MONITOR[📊 Monitoring<br/>Wave: 6<br/>Observability]
    end
    
    NAMESPACE --> CONFIG
    NAMESPACE --> EUREKA
    
    CONFIG --> REDIS
    CONFIG --> POSTGRES
    CONFIG --> KAFKA
    EUREKA --> REDIS
    EUREKA --> POSTGRES
    EUREKA --> KAFKA
    
    REDIS --> GATEWAY
    POSTGRES --> GATEWAY
    KAFKA --> GATEWAY
    CONFIG --> GATEWAY
    EUREKA --> GATEWAY
    
    GATEWAY --> USER
    GATEWAY --> PRODUCT
    POSTGRES --> USER
    POSTGRES --> PRODUCT
    REDIS --> USER
    REDIS --> PRODUCT
    KAFKA --> USER
    KAFKA --> PRODUCT
    
    USER --> INGRESS
    PRODUCT --> INGRESS
    GATEWAY --> INGRESS
    
    INGRESS --> MONITOR

    style NAMESPACE fill:#e3f2fd,stroke:#1976d2
    style CONFIG fill:#fff3e0,stroke:#f57c00
    style EUREKA fill:#f3e5f5,stroke:#7b1fa2
    style GATEWAY fill:#e8f5e8,stroke:#388e3c
    style INGRESS fill:#fce4ec,stroke:#880e4f
```

## 🌍 Environment Management

### Environment Configuration Matrix

| Component | Development | Staging | Production |
|-----------|------------|---------|------------|
| **Replicas** | 1 | 2 | 3+ |
| **Resources** | Minimal | Medium | High |
| **Logging** | DEBUG | INFO | ERROR |
| **Service Type** | NodePort | LoadBalancer | LoadBalancer |
| **Ingress** | Local domains | Staging domains | Production domains |
| **Database** | Single instance | HA pair | HA cluster |
| **Auto-scaling** | Disabled | Basic | Advanced |
| **Monitoring** | Basic | Full | Enterprise |

### Environment-Specific Kustomization

```mermaid
graph LR
    subgraph "Base Configuration"
        BASE_DEPLOY[📦 Deployment<br/>2 replicas<br/>Standard resources]
        BASE_SVC[🔧 Service<br/>ClusterIP<br/>Standard ports]
        BASE_CM[⚙️ ConfigMap<br/>Default settings<br/>INFO logging]
    end
    
    subgraph "Development Overlay"
        DEV_PATCH[🛠️ Patches<br/>• 1 replica<br/>• DEBUG logging<br/>• NodePort service<br/>• Reduced resources]
        DEV_CM[⚙️ Dev ConfigMap<br/>• Debug settings<br/>• Test endpoints<br/>• Mock services]
    end
    
    subgraph "Production Overlay"
        PROD_PATCH[🚀 Patches<br/>• 5 replicas<br/>• ERROR logging<br/>• LoadBalancer<br/>• High resources]
        PROD_CM[⚙️ Prod ConfigMap<br/>• Security hardened<br/>• Performance tuned<br/>• Monitoring enabled]
    end
    
    BASE_DEPLOY --> DEV_PATCH
    BASE_SVC --> DEV_PATCH
    BASE_CM --> DEV_CM
    
    BASE_DEPLOY --> PROD_PATCH
    BASE_SVC --> PROD_PATCH
    BASE_CM --> PROD_CM

    style BASE_DEPLOY fill:#e3f2fd,stroke:#1976d2
    style DEV_PATCH fill:#f3e5f5,stroke:#7b1fa2
    style PROD_PATCH fill:#e8f5e8,stroke:#388e3c
```

## 📊 Monitoring & Health Checks

### ArgoCD Application Health Dashboard

```mermaid
graph TB
    subgraph "ArgoCD Health Monitoring"
        ARGOCD_UI[🖥️ ArgoCD UI<br/>https://argocd.yourdomain.com]
        
        subgraph "Application Status"
            HEALTHY[💚 Healthy<br/>All resources synced<br/>All pods running]
            PROGRESSING[🟡 Progressing<br/>Deployment in progress<br/>Rolling update]
            DEGRADED[🔴 Degraded<br/>Some pods failing<br/>Resource issues]
            SUSPENDED[⏸️ Suspended<br/>Manual intervention<br/>Sync disabled]
        end
        
        subgraph "Sync Status"
            SYNCED[✅ Synced<br/>Git = Cluster<br/>No drift detected]
            OUT_OF_SYNC[❌ OutOfSync<br/>Configuration drift<br/>Manual changes detected]
            UNKNOWN[❓ Unknown<br/>Sync status unclear<br/>Investigation needed]
        end
    end
    
    subgraph "Monitoring Integration"
        PROMETHEUS[📈 Prometheus<br/>ArgoCD metrics<br/>Application metrics]
        GRAFANA[📊 Grafana<br/>ArgoCD dashboard<br/>Application dashboard]
        ALERTS[🚨 Alertmanager<br/>Sync failures<br/>Health degradation]
    end
    
    ARGOCD_UI --> HEALTHY
    ARGOCD_UI --> PROGRESSING
    ARGOCD_UI --> DEGRADED
    ARGOCD_UI --> SUSPENDED
    
    ARGOCD_UI --> SYNCED
    ARGOCD_UI --> OUT_OF_SYNC
    ARGOCD_UI --> UNKNOWN
    
    ARGOCD_UI --> PROMETHEUS
    PROMETHEUS --> GRAFANA
    PROMETHEUS --> ALERTS

    style HEALTHY fill:#c8e6c9,stroke:#4caf50
    style DEGRADED fill:#ffcdd2,stroke:#f44336
    style SYNCED fill:#c8e6c9,stroke:#4caf50
    style OUT_OF_SYNC fill:#ffcdd2,stroke:#f44336
```

### Health Check Endpoints

| Service | Health Endpoint | Port | ArgoCD Health Check |
|---------|----------------|------|-------------------|
| **Config Server** | `/actuator/health` | 8888 | ✅ Spring Boot Actuator |
| **Eureka Server** | `/actuator/health` | 8761 | ✅ Spring Boot Actuator |
| **API Gateway** | `/actuator/health` | 8099 | ✅ Spring Boot Actuator |
| **User Service** | `/actuator/health` | 8080 | ✅ Spring Boot Actuator |
| **Product Service** | `/actuator/health` | 8081 | ✅ Spring Boot Actuator |
| **ArgoCD** | `/healthz` | 443 | ✅ ArgoCD Native |

## 🔧 Troubleshooting

### Common Issues & Solutions

#### 🚨 Application Stuck in Progressing State

```mermaid
flowchart TD
    STUCK[🔄 Application Stuck<br/>in Progressing State]
    
    STUCK --> CHECK_PODS{📦 Check Pod Status}
    CHECK_PODS -->|Pods Failing| POD_LOGS[📋 Check Pod Logs<br/>kubectl logs pod-name]
    CHECK_PODS -->|Pods Pending| RESOURCES[🔍 Check Resources<br/>kubectl describe pod]
    CHECK_PODS -->|Pods Running| HEALTH_CHECK[💊 Check Health Endpoints]
    
    POD_LOGS --> FIX_CONFIG[🔧 Fix Configuration<br/>Update manifests]
    RESOURCES --> ADD_RESOURCES[➕ Add Resources<br/>Increase limits/requests]
    HEALTH_CHECK --> FIX_HEALTH[🔧 Fix Health Checks<br/>Adjust probe settings]
    
    FIX_CONFIG --> COMMIT[📝 Commit & Push]
    ADD_RESOURCES --> COMMIT
    FIX_HEALTH --> COMMIT
    
    COMMIT --> AUTO_SYNC[🔄 ArgoCD Auto-Sync]
    AUTO_SYNC --> RESOLVED[✅ Issue Resolved]

    style STUCK fill:#ffcdd2,stroke:#f44336
    style RESOLVED fill:#c8e6c9,stroke:#4caf50
```

#### 🔍 Debugging Commands

```bash
# Check ArgoCD application status
argocd app get <app-name>

# View application logs
argocd app logs <app-name>

# Force refresh application
argocd app sync <app-name> --force

# Check Kubernetes events
kubectl get events --sort-by='.lastTimestamp' -n <namespace>

# Describe problematic resources
kubectl describe deployment <deployment-name> -n <namespace>

# Check pod logs
kubectl logs -f deployment/<deployment-name> -n <namespace>

# Restart deployment
kubectl rollout restart deployment/<deployment-name> -n <namespace>
```

### Sync Failure Troubleshooting

| Error Type | Symptoms | Solution |
|------------|----------|----------|
| **Resource Conflict** | `resource already exists` | Enable prune or delete conflicting resources |
| **Permission Denied** | `forbidden: access denied` | Check RBAC permissions for ArgoCD |
| **Invalid Manifest** | `error validating data` | Validate YAML syntax and Kubernetes API |
| **Hook Failure** | `hook job failed` | Check pre/post sync hooks and fix scripts |
| **Health Check Timeout** | `health check timeout` | Adjust health check timeouts or fix app health |

## 🎯 GitOps Best Practices

### 1. 📝 Commit Message Convention

```
<type>(<scope>): <description>

Types:
- feat: New feature or application
- fix: Bug fix or configuration correction
- refactor: Code/config restructuring
- docs: Documentation updates
- chore: Maintenance tasks

Examples:
feat(microservices): add cart service deployment
fix(infrastructure): correct eureka server health check
refactor(kustomize): reorganize base configurations
```

### 2. 🔄 Branching Strategy

```mermaid
graph LR
    subgraph "Git Workflow"
        MAIN[🌟 main<br/>Production ready<br/>Auto-deploy to prod]
        DEVELOP[🔧 develop<br/>Integration branch<br/>Auto-deploy to staging]
        FEATURE[🌿 feature/*<br/>Feature development<br/>Deploy to dev]
    end
    
    subgraph "Environments"
        DEV[🛠️ Development<br/>Feature testing]
        STAGING[🔧 Staging<br/>Integration testing]
        PROD[🚀 Production<br/>Live environment]
    end
    
    FEATURE --> DEVELOP
    DEVELOP --> MAIN
    
    FEATURE -.-> DEV
    DEVELOP -.-> STAGING
    MAIN -.-> PROD

    style MAIN fill:#e8f5e8,stroke:#388e3c
    style DEVELOP fill:#fff3e0,stroke:#f57c00
    style FEATURE fill:#f3e5f5,stroke:#7b1fa2
```

### 3. 🔒 Security Considerations

- **🔐 Secrets Management**: Use Kubernetes secrets or external secret managers
- **🔑 RBAC**: Implement least-privilege access controls
- **📝 Audit Logging**: Enable comprehensive audit trails
- **🔍 Vulnerability Scanning**: Regular container and manifest scanning
- **🚫 No Sensitive Data**: Never commit sensitive information

## 🚀 Advanced Features

### Progressive Delivery with ArgoCD

```mermaid
graph TB
    subgraph "Canary Deployment Strategy"
        NEW_VERSION[🆕 New Version<br/>Git Commit]
        NEW_VERSION --> CANARY[🐦 Canary<br/>5% traffic]
        CANARY --> ANALYSIS[📊 Analysis<br/>Metrics & Health]
        ANALYSIS -->|Success| PROMOTE[⬆️ Promote<br/>100% traffic]
        ANALYSIS -->|Failure| ROLLBACK[↩️ Rollback<br/>Previous version]
        PROMOTE --> STABLE[✅ Stable<br/>Deployment complete]
    end
    
    subgraph "Blue-Green Deployment"
        BLUE[🔵 Blue<br/>Current production]
        GREEN[🟢 Green<br/>New version]
        SWITCH[🔄 Traffic Switch<br/>Instant cutover]
        BLUE --> SWITCH
        GREEN --> SWITCH
        SWITCH --> VALIDATION[✅ Validation]
    end

    style CANARY fill:#fff3e0,stroke:#f57c00
    style PROMOTE fill:#c8e6c9,stroke:#4caf50
    style ROLLBACK fill:#ffcdd2,stroke:#f44336
    style STABLE fill:#e1f5fe,stroke:#01579b
```

### Multi-Cluster Management

```mermaid
graph TB
    subgraph "GitOps Control Plane"
        ARGOCD_MGMT[🎯 ArgoCD Management<br/>Central control cluster]
    end
    
    subgraph "Target Clusters"
        DEV_CLUSTER[🛠️ Development Cluster<br/>Region: us-west-1]
        STAGING_CLUSTER[🔧 Staging Cluster<br/>Region: us-east-1]
        PROD_CLUSTER[🚀 Production Cluster<br/>Region: us-east-1, us-west-2]
    end
    
    subgraph "Git Repository"
        GITOPS_REPO[📁 GitOps Repository<br/>Single source of truth]
    end
    
    GITOPS_REPO --> ARGOCD_MGMT
    ARGOCD_MGMT --> DEV_CLUSTER
    ARGOCD_MGMT --> STAGING_CLUSTER
    ARGOCD_MGMT --> PROD_CLUSTER
    
    style ARGOCD_MGMT fill:#e1f5fe,stroke:#01579b
    style GITOPS_REPO fill:#e8f5e8,stroke:#388e3c
```

## 🤝 Contributing

### Contributing Workflow

1. **🍴 Fork** the repository
2. **🌿 Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **📝 Commit** your changes (`git commit -m 'feat(scope): add amazing feature'`)
4. **🚀 Push** to the branch (`git push origin feature/amazing-feature`)
5. **📝 Open** a Pull Request

### Pull Request Guidelines

- **✅ Validate** all Kubernetes manifests
- **🧪 Test** in development environment first
- **📖 Update** documentation if needed
- **🔍 Include** ArgoCD sync status screenshots
- **📋 Follow** commit message conventions

### Environment Promotion Process

```mermaid
sequenceDiagram
    participant Dev as 👨‍💻 Developer
    participant PR as 📝 Pull Request
    participant CI as 🔄 CI/CD Pipeline
    participant DevEnv as 🛠️ Dev Environment
    participant StagingEnv as 🔧 Staging Environment
    participant ProdEnv as 🚀 Production Environment
    
    Dev->>PR: 1. Create PR with changes
    PR->>CI: 2. Trigger validation pipeline
    CI->>CI: 3. Validate manifests
    CI->>CI: 4. Run security scans
    CI->>DevEnv: 5. Deploy to dev environment
    DevEnv->>Dev: 6. Manual testing & validation
    Dev->>PR: 7. Approve and merge PR
    PR->>StagingEnv: 8. Auto-deploy to staging
    StagingEnv->>Dev: 9. Integration testing
    Dev->>ProdEnv: 10. Manual promotion to production
    ProdEnv->>Dev: 11. Production validation
```

## 📚 Additional Resources

### 🔗 Useful Links

- **📖 ArgoCD Documentation**: [https://argo-cd.readthedocs.io/](https://argo-cd.readthedocs.io/)
- **⚙️ Kustomize Documentation**: [https://kustomize.io/](https://kustomize.io/)
- **☸️ Kubernetes Documentation**: [https://kubernetes.io/docs/](https://kubernetes.io/docs/)
- **🔧 GitOps Best Practices**: [https://opengitops.dev/](https://opengitops.dev/)

### 📞 Support & Community

- **🐛 Issues**: [GitHub Issues](https://github.com/ZakariaRek/gitops-repo_ArgoCD/issues)
- **💬 Discussions**: [GitHub Discussions](https://github.com/ZakariaRek/gitops-repo_ArgoCD/discussions)
- **📧 Email**: support@nexuscommerce.io
- **💬 Slack**: [Nexus Commerce DevOps](https://nexuscommerce.slack.com)

### 🏷️ Versioning & Releases

We use [Semantic Versioning](https://semver.org/) for our releases:

- **Major**: Breaking changes requiring manual intervention
- **Minor**: New features, backward compatible
- **Patch**: Bug fixes and security updates

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**🌟 Star this repository if it helped you! 🌟**

*"GitOps: Where Git becomes the single source of truth, and deployments become as simple as a git push."*

![Made with ❤️](https://img.shields.io/badge/Made%20with-❤️-red.svg)
![GitOps](https://img.shields.io/badge/GitOps-100000?style=flat&logo=git&logoColor=white)
![ArgoCD](https://img.shields.io/badge/ArgoCD-EF7B4D?style=flat&logo=argo&logoColor=white)

</div>
