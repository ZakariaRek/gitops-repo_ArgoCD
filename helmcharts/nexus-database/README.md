# NexusCommerce Database Helm Chart

A comprehensive Helm chart for deploying the complete NexusCommerce database stack including MongoDB, PostgreSQL, Redis, and Kafka/Zookeeper messaging systems.

## Overview

This chart deploys a full database infrastructure for the NexusCommerce microservices platform, providing:

- **MongoDB instances** for cart and user services
- **PostgreSQL databases** for product, payment, order, loyalty, and shipping services  
- **Redis** for caching and session management
- **Kafka & Zookeeper** for event streaming and messaging

## Prerequisites

- Kubernetes 1.20+
- Helm 3.8+
- StorageClass configured for persistent volumes
- At least 8GB RAM and 4 CPU cores available in cluster

## Quick Start

### 1. Add the repository (if applicable)
```bash
helm repo add nexuscommerce https://charts.nexuscommerce.com
helm repo update
```

### 2. Install for development
```bash
# Using make (recommended)
make dev

# Or using helm directly
helm install nexus-database . -f values-dev.yaml --namespace data --create-namespace
```

### 3. Install for production
```bash
# Using make (recommended)
make prod

# Or using the deployment script
./deploy.sh -e prod -u
```

## Configuration

### Environment-Specific Deployments

The chart supports three environments with different resource allocations:

| Environment | Replicas | Resources | Storage | Purpose |
|-------------|----------|-----------|---------|---------|
| **dev** | Minimal (1) | Low | Small | Development & testing |
| **staging** | Medium (2) | Medium | Medium | Pre-production testing |
| **prod** | High (3) | High | Large | Production workloads |

### Values Files

- `values.yaml` - Default configuration
- `values-dev.yaml` - Development environment
- `values-staging.yaml` - Staging environment  
- `values-prod.yaml` - Production environment

## Installation

### Using Make (Recommended)

```bash
# Development
make dev

# Staging
make staging

# Production
make prod

# Upgrade existing deployment
make upgrade ENVIRONMENT=prod

# Dry run
make dry-run ENVIRONMENT=staging
```

### Using Deployment Script

```bash
# Install development
./deploy.sh -e dev

# Install production with upgrade
./deploy.sh -e prod -u

# Dry run for staging
./deploy.sh -e staging -d
```

### Using Helm Directly

```bash
# Install
helm install nexus-database . -f values-dev.yaml --namespace data --create-namespace

# Upgrade
helm upgrade nexus-database . -f values-prod.yaml --namespace data

# Uninstall
helm uninstall nexus-database --namespace data
```

## Configuration Parameters

### Global Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.namespace` | Kubernetes namespace | `data` |
| `global.environment` | Environment name | `production` |
| `global.storageClass` | Storage class for PVs | `standard` |
| `global.nodeSelector` | Node selector for pods | `{node-role: data}` |

### MongoDB Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `mongodb.enabled` | Enable MongoDB deployment | `true` |
| `mongodb.cart.enabled` | Enable cart MongoDB | `true` |
| `mongodb.cart.replicas` | Number of cart MongoDB replicas | `2` |
| `mongodb.cart.image.repository` | MongoDB image repository | `mongo` |
| `mongodb.cart.image.tag` | MongoDB image tag | `7.0` |
| `mongodb.cart.database.name` | Cart database name | `cartdb` |
| `mongodb.cart.auth.username` | Cart MongoDB username | `cartservice` |
| `mongodb.cart.storage.data.size` | Cart data storage size | `10Gi` |

### PostgreSQL Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `postgresql.enabled` | Enable PostgreSQL deployment | `true` |
| `postgresql.product.enabled` | Enable product PostgreSQL | `true` |
| `postgresql.product.database.name` | Product database name | `productdb` |
| `postgresql.product.auth.username` | Product DB username | `productservice` |
| `postgresql.product.storage.size` | Product DB storage size | `10Gi` |

### Redis Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `redis.enabled` | Enable Redis deployment | `true` |
| `redis.image.repository` | Redis image repository | `redis` |
| `redis.image.tag` | Redis image tag | `7.2-alpine` |
| `redis.config.maxmemory` | Redis max memory | `512mb` |
| `redis.storage.size` | Redis storage size | `2Gi` |

### Messaging Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `messaging.enabled` | Enable Kafka/Zookeeper | `true` |
| `messaging.kafka.enabled` | Enable Kafka | `true` |
| `messaging.kafka.image.tag` | Kafka image tag | `7.4.0` |
| `messaging.kafka.config.numPartitions` | Default partitions | `3` |
| `messaging.zookeeper.enabled` | Enable Zookeeper | `true` |

## Database Connections

After deployment, services can connect using these URLs:

### MongoDB
```
# Cart Service
mongodb://cart-mongodb-headless.data.svc.cluster.local:27017/cartdb

# User Service  
mongodb://user-mongodb-headless.data.svc.cluster.local:27017/userdb
```

### PostgreSQL
```
# Product Service
product-postgres-service.data.svc.cluster.local:5432/productdb

# Payment Service
payment-postgres-service.data.svc.cluster.local:5432/paymentdb

# Order Service
order-postgres-service.data.svc.cluster.local:5432/orderdb

# Loyalty Service
loyalty-postgres-service.data.svc.cluster.local:5432/loyalty-service

# Shipping Service
shipping-postgres-service.data.svc.cluster.local:5432/shippingdb
```

### Redis
```
redis-service.data.svc.cluster.local:6379
```

### Kafka
```
kafka-service.data.svc.cluster.local:9092
```

## Monitoring & Observability

The chart includes optional monitoring components:

```yaml
monitoring:
  enabled: true
  prometheus:
    enabled: true
```

This exposes metrics endpoints for:
- Database health monitoring
- Performance metrics
- Resource utilization

## Security

### Development
- Basic authentication
- No network policies
- Simplified configuration

### Production
- Strong passwords (use Kubernetes secrets)
- Network policies enabled
- Encrypted connections
- RBAC integration

### Updating Secrets

```bash
# Update MongoDB password
kubectl create secret generic cart-mongodb-secret \
  --from-literal=username=cartservice \
  --from-literal=password=your-new-password \
  --namespace data \
  --dry-run=client -o yaml | kubectl apply -f -

# Update PostgreSQL password
kubectl create secret generic product-postgres-secret \
  --from-literal=username=productservice \
  --from-literal=password=your-new-password \
  --namespace data \
  --dry-run=client -o yaml | kubectl apply -f -
```

## Backup & Recovery

### Enabling Backups

```yaml
backup:
  enabled: true
  schedule: "0 2 * * *"  # Daily at 2 AM
  retention: 30  # Keep for 30 days
```

### Manual Backup

```bash
# MongoDB backup
kubectl exec -n data cart-mongodb-0 -- mongodump --out /tmp/backup

# PostgreSQL backup
kubectl exec -n data product-postgres-0 -- pg_dump productdb > backup.sql
```

## Troubleshooting

### Common Issues

1. **Pods stuck in Pending**
   ```bash
   kubectl describe pod -n data
   # Check for resource constraints or storage issues
   ```

2. **MongoDB connection failures**
   ```bash
   kubectl logs -n data cart-mongodb-0
   # Check authentication and network connectivity
   ```

3. **PostgreSQL startup issues**
   ```bash
   kubectl logs -n data product-postgres-0
   # Check for permission or configuration issues
   ```

### Useful Commands

```bash
# Check all pods status
make status

# View logs for all database pods
make logs

# Show connection information
make connect

# Test connectivity from within cluster
kubectl run -n data debug --image=busybox -it --rm -- sh
# Then test: nc -zv redis-service.data.svc.cluster.local 6379
```

### Scaling

```bash
# Scale MongoDB replicas
helm upgrade nexus-database . \
  --set mongodb.cart.replicas=3 \
  --namespace data

# Scale PostgreSQL (requires manual setup for read replicas)
kubectl scale statefulset product-postgres --replicas=2 -n data
```

## Uninstallation

### Complete Removal (⚠️ Data Loss)
```bash
# Using make
make clean

# Using script
./undeploy.sh -f

# Using helm
helm uninstall nexus-database -n data
kubectl delete pvc --all -n data
```

### Keep Data (Preserve PVCs)
```bash
./undeploy.sh -k
```

## Development

### Chart Development

```bash
# Lint the chart
make lint

# Test template rendering
make test

# Debug template issues
helm template nexus-database . -f values-dev.yaml --debug
```

### Adding New Databases

1. Add configuration to `values.yaml`
2. Create templates in `templates/` directory
3. Update `_helpers.tpl` with new labels
4. Test with `helm template`
5. Update documentation

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test thoroughly
4. Update documentation
5. Submit a pull request

## License

This chart is licensed under the MIT License. See LICENSE file for details.

## Support

- **Documentation**: [docs.nexuscommerce.com](https://docs.nexuscommerce.com)
- **Issues**: [GitHub Issues](https://github.com/nexuscommerce/helm-charts/issues)
- **Discord**: [NexusCommerce Community](https://discord.gg/nexuscommerce)

---

# .helmignore
# Patterns to ignore when building packages.
# This supports shell glob matching, relative path matching, and
# negation (prefixed with !). Only one pattern per line.
.DS_Store
# Common VCS dirs
.git/
.gitignore
.bzr/
.bzrignore
.hg/
.hgignore
.svn/
# Common backup files
*.swp
*.bak
*.tmp
*.orig
*~
# Various IDEs
.project
.idea/
*.tmproj
.vscode/

# Helm build artifacts
*.tgz
.helmignore

# Development files
deploy.sh
undeploy.sh
Makefile
README.md
.github/
docs/
examples/
tests/

---

# NOTES.txt - Post-installation notes
1. Get the database connection information by running:
   
   make connect

2. Monitor the deployment status:
   
   kubectl get all -n {{ .Values.global.namespace }}

3. View logs for troubleshooting:
   
   make logs

4. The following databases are now available:

   {{- if .Values.mongodb.enabled }}
   MongoDB Instances:
   {{- if .Values.mongodb.cart.enabled }}
   - Cart: mongodb://cart-mongodb-headless.{{ .Values.global.namespace }}.svc.cluster.local:27017/{{ .Values.mongodb.cart.database.name }}
   {{- end }}
   {{- if .Values.mongodb.user.enabled }}
   - User: mongodb://user-mongodb-headless.{{ .Values.global.namespace }}.svc.cluster.local:27017/{{ .Values.mongodb.user.database.name }}
   {{- end }}
   {{- end }}

   {{- if .Values.postgresql.enabled }}
   PostgreSQL Instances:
   {{- if .Values.postgresql.product.enabled }}
   - Product: product-postgres-service.{{ .Values.global.namespace }}.svc.cluster.local:5432/{{ .Values.postgresql.product.database.name }}
   {{- end }}
   {{- if .Values.postgresql.payment.enabled }}
   - Payment: payment-postgres-service.{{ .Values.global.namespace }}.svc.cluster.local:5432/{{ .Values.postgresql.payment.database.name }}
   {{- end }}
   {{- if .Values.postgresql.order.enabled }}
   - Order: order-postgres-service.{{ .Values.global.namespace }}.svc.cluster.local:5432/{{ .Values.postgresql.order.database.name }}
   {{- end }}
   {{- if .Values.postgresql.loyalty.enabled }}
   - Loyalty: loyalty-postgres-service.{{ .Values.global.namespace }}.svc.cluster.local:5432/{{ .Values.postgresql.loyalty.database.name }}
   {{- end }}
   {{- if .Values.postgresql.shipping.enabled }}
   - Shipping: shipping-postgres-service.{{ .Values.global.namespace }}.svc.cluster.local:5432/{{ .Values.postgresql.shipping.database.name }}
   {{- end }}
   {{- end }}

   {{- if .Values.redis.enabled }}
   Redis Cache:
   - redis-service.{{ .Values.global.namespace }}.svc.cluster.local:6379
   {{- end }}

   {{- if .Values.messaging.enabled }}
   {{- if .Values.messaging.kafka.enabled }}
   Kafka Messaging:
   - kafka-service.{{ .Values.global.namespace }}.svc.cluster.local:9092
   {{- end }}
   {{- end }}

5. For credentials, check the secrets:
   
   kubectl get secrets -n {{ .Values.global.namespace }}

{{- if eq .Values.global.environment "dev" }}

6. Development Environment Notes:
   - Reduced resource allocations for local development
   - Single replica for most services
   - Shorter data retention periods
   - Simplified security configurations

{{- end }}

{{- if eq .Values.global.environment "prod" }}

7. Production Environment Notes:
   - High availability with multiple replicas
   - Enhanced security configurations
   - Extended data retention periods
   - Monitoring and backup enabled

   ⚠️  Remember to:
   - Update default passwords
   - Configure proper backup schedules
   - Set up monitoring alerts
   - Review security settings

{{- end }}

For more information, visit: https://docs.nexuscommerce.com/database-setup

---

# .github/workflows/helm-lint.yml
name: Helm Chart Lint and Test

on:
  push:
    branches: [ main, develop ]
    paths: [ 'helm-charts/nexus-database/**' ]
  pull_request:
    branches: [ main ]
    paths: [ 'helm-charts/nexus-database/**' ]

jobs:
  lint-test:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v3
      with:
        fetch-depth: 0

    - name: Set up Helm
      uses: azure/setup-helm@v3
      with:
        version: v3.12.1

    - name: Set up chart-testing
      uses: helm/chart-testing-action@v2.4.0

    - name: Run chart-testing (list-changed)
      id: list-changed
      run: |
        changed=$(ct list-changed --target-branch ${{ github.event.repository.default_branch }})
        if [[ -n "$changed" ]]; then
          echo "::set-output name=changed::true"
        fi

    - name: Run chart-testing (lint)
      run: ct lint --target-branch ${{ github.event.repository.default_branch }}

    - name: Create kind cluster
      uses: helm/kind-action@v1.7.0
      if: steps.list-changed.outputs.changed == 'true'

    - name: Run chart-testing (install)
      run: ct install --target-branch ${{ github.event.repository.default_branch }}
      if: steps.list-changed.outputs.changed == 'true'