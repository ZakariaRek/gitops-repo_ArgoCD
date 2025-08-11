#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
ENVIRONMENT="dev"
NAMESPACE="data"
RELEASE_NAME="nexus-database"
DRY_RUN=false
UPGRADE=false

# Function to print colored output
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -e, --environment   Environment to deploy (dev|staging|prod) [default: dev]"
    echo "  -n, --namespace     Kubernetes namespace [default: data]"
    echo "  -r, --release       Helm release name [default: nexus-database]"
    echo "  -d, --dry-run       Perform a dry run"
    echo "  -u, --upgrade       Upgrade existing release"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -e dev                    # Deploy to development"
    echo "  $0 -e prod -u                # Upgrade production release"
    echo "  $0 -e staging -d             # Dry run for staging"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -n|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        -r|--release)
            RELEASE_NAME="$2"
            shift 2
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -u|--upgrade)
            UPGRADE=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    print_message $RED "Error: Environment must be one of: dev, staging, prod"
    exit 1
fi

# Check if helm is installed
if ! command -v helm &> /dev/null; then
    print_message $RED "Error: Helm is not installed"
    exit 1
fi

# Check if kubectl is installed and configured
if ! command -v kubectl &> /dev/null; then
    print_message $RED "Error: kubectl is not installed"
    exit 1
fi

if ! kubectl cluster-info &> /dev/null; then
    print_message $RED "Error: kubectl is not configured or cluster is not reachable"
    exit 1
fi

# Set values file based on environment
VALUES_FILE="values-${ENVIRONMENT}.yaml"

if [[ ! -f "$VALUES_FILE" ]]; then
    print_message $RED "Error: Values file $VALUES_FILE not found"
    exit 1
fi

print_message $BLUE "=== NexusCommerce Database Deployment ==="
print_message $YELLOW "Environment: $ENVIRONMENT"
print_message $YELLOW "Namespace: $NAMESPACE"
print_message $YELLOW "Release: $RELEASE_NAME"
print_message $YELLOW "Values file: $VALUES_FILE"

# Create namespace if it doesn't exist
if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
    print_message $YELLOW "Creating namespace: $NAMESPACE"
    kubectl create namespace "$NAMESPACE"
fi

# Prepare helm command
HELM_CMD="helm"

if [[ "$UPGRADE" == true ]]; then
    HELM_CMD="$HELM_CMD upgrade"
else
    HELM_CMD="$HELM_CMD install"
fi

HELM_CMD="$HELM_CMD $RELEASE_NAME . -f $VALUES_FILE --namespace $NAMESPACE"

if [[ "$DRY_RUN" == true ]]; then
    HELM_CMD="$HELM_CMD --dry-run --debug"
    print_message $YELLOW "Running in dry-run mode..."
else
    HELM_CMD="$HELM_CMD --create-namespace"
fi

# Add environment-specific flags
case $ENVIRONMENT in
    prod)
        HELM_CMD="$HELM_CMD --timeout 15m0s --wait"
        ;;
    staging)
        HELM_CMD="$HELM_CMD --timeout 10m0s --wait"
        ;;
    dev)
        HELM_CMD="$HELM_CMD --timeout 5m0s"
        ;;
esac

# Execute helm command
print_message $BLUE "Executing: $HELM_CMD"
if eval "$HELM_CMD"; then
    if [[ "$DRY_RUN" == false ]]; then
        print_message $GREEN "✅ Deployment successful!"
        print_message $BLUE "Checking deployment status..."

        # Wait for deployments to be ready
        kubectl rollout status deployment -n "$NAMESPACE" --timeout=300s 2>/dev/null || true
        kubectl rollout status statefulset -n "$NAMESPACE" --timeout=300s 2>/dev/null || true

        print_message $GREEN "🚀 NexusCommerce Database is ready!"

        # Show connection information
        print_message $BLUE "\n=== Connection Information ==="
        echo "MongoDB URLs:"
        echo "  Cart: mongodb://cart-mongodb-headless.$NAMESPACE.svc.cluster.local:27017/cartdb"
        echo "  User: mongodb://user-mongodb-headless.$NAMESPACE.svc.cluster.local:27017/userdb"
        echo ""
        echo "PostgreSQL URLs:"
        echo "  Product: product-postgres-service.$NAMESPACE.svc.cluster.local:5432/productdb"
        echo "  Payment: payment-postgres-service.$NAMESPACE.svc.cluster.local:5432/paymentdb"
        echo "  Order: order-postgres-service.$NAMESPACE.svc.cluster.local:5432/orderdb"
        echo "  Loyalty: loyalty-postgres-service.$NAMESPACE.svc.cluster.local:5432/loyalty-service"
        echo "  Shipping: shipping-postgres-service.$NAMESPACE.svc.cluster.local:5432/shippingdb"
        echo ""
        echo "Redis URL:"
        echo "  redis-service.$NAMESPACE.svc.cluster.local:6379"
        echo ""
        echo "Kafka URL:"
        echo "  kafka-service.$NAMESPACE.svc.cluster.local:9092"
    else
        print_message $GREEN "✅ Dry run completed successfully!"
    fi
else
    print_message $RED "❌ Deployment failed!"
    exit 1
fi

---
# undeploy.sh - Cleanup Script
#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
NAMESPACE="data"
RELEASE_NAME="nexus-database"
FORCE=false
KEEP_PVCS=false

# Function to print colored output
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -n, --namespace     Kubernetes namespace [default: data]"
    echo "  -r, --release       Helm release name [default: nexus-database]"
    echo "  -f, --force         Force deletion without confirmation"
    echo "  -k, --keep-pvcs     Keep PersistentVolumeClaims (preserve data)"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                           # Interactive deletion"
    echo "  $0 -f                        # Force deletion"
    echo "  $0 -k                        # Keep data (PVCs)"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        -r|--release)
            RELEASE_NAME="$2"
            shift 2
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -k|--keep-pvcs)
            KEEP_PVCS=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option $1"
            show_usage
            exit 1
            ;;
    esac
done

print_message $BLUE "=== NexusCommerce Database Cleanup ==="
print_message $YELLOW "Namespace: $NAMESPACE"
print_message $YELLOW "Release: $RELEASE_NAME"

if [[ "$KEEP_PVCS" == true ]]; then
    print_message $YELLOW "PVCs will be preserved"
else
    print_message $RED "⚠️  PVCs will be deleted (data will be lost)"
fi

# Confirmation prompt
if [[ "$FORCE" == false ]]; then
    print_message $YELLOW "\nThis will delete the NexusCommerce database deployment."
    if [[ "$KEEP_PVCS" == false ]]; then
        print_message $RED "WARNING: All database data will be permanently lost!"
    fi
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_message $BLUE "Operation cancelled."
        exit 0
    fi
fi

# Check if helm release exists
if ! helm list -n "$NAMESPACE" | grep -q "$RELEASE_NAME"; then
    print_message $YELLOW "Helm release '$RELEASE_NAME' not found in namespace '$NAMESPACE'"
else
    print_message $BLUE "Uninstalling Helm release..."
    helm uninstall "$RELEASE_NAME" -n "$NAMESPACE"
    print_message $GREEN "✅ Helm release uninstalled"
fi

# Delete PVCs if not keeping them
if [[ "$KEEP_PVCS" == false ]]; then
    print_message $BLUE "Deleting PersistentVolumeClaims..."
    kubectl delete pvc -n "$NAMESPACE" --all 2>/dev/null || true
    print_message $GREEN "✅ PVCs deleted"
else
    print_message $YELLOW "Keeping PVCs as requested"
fi

# Optionally delete namespace if empty
if kubectl get all -n "$NAMESPACE" 2>/dev/null | grep -q "No resources found"; then
    if [[ "$FORCE" == true ]]; then
        kubectl delete namespace "$NAMESPACE" 2>/dev/null || true
        print_message $GREEN "✅ Empty namespace deleted"
    else
        read -p "Namespace is empty. Delete it? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            kubectl delete namespace "$NAMESPACE" 2>/dev/null || true
            print_message $GREEN "✅ Namespace deleted"
        fi
    fi
fi

print_message $GREEN "🧹 Cleanup completed!"

---
# Makefile - Build automation
.PHONY: help install upgrade uninstall dry-run lint test dev staging prod clean

# Default values
ENVIRONMENT ?= dev
NAMESPACE ?= data
RELEASE_NAME ?= nexus-database

help: ## Show this help message
	@echo "NexusCommerce Database Helm Chart"
	@echo ""
	@echo "Available commands:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install the chart (ENV=dev|staging|prod)
	@echo "Installing nexus-database for $(ENVIRONMENT) environment..."
	./deploy.sh -e $(ENVIRONMENT) -n $(NAMESPACE) -r $(RELEASE_NAME)

upgrade: ## Upgrade existing release (ENV=dev|staging|prod)
	@echo "Upgrading nexus-database for $(ENVIRONMENT) environment..."
	./deploy.sh -e $(ENVIRONMENT) -n $(NAMESPACE) -r $(RELEASE_NAME) --upgrade

uninstall: ## Uninstall the chart
	@echo "Uninstalling nexus-database..."
	./undeploy.sh -n $(NAMESPACE) -r $(RELEASE_NAME)

dry-run: ## Perform a dry run (ENV=dev|staging|prod)
	@echo "Dry run for $(ENVIRONMENT) environment..."
	./deploy.sh -e $(ENVIRONMENT) -n $(NAMESPACE) -r $(RELEASE_NAME) --dry-run

lint: ## Lint the helm chart
	@echo "Linting helm chart..."
	helm lint .

test: ## Test the helm chart
	@echo "Testing helm chart..."
	helm template $(RELEASE_NAME) . -f values-dev.yaml --debug

dev: ## Deploy to development
	$(MAKE) install ENVIRONMENT=dev

staging: ## Deploy to staging
	$(MAKE) install ENVIRONMENT=staging

prod: ## Deploy to production
	$(MAKE) install ENVIRONMENT=prod

clean: ## Clean up development environment
	$(MAKE) uninstall ENVIRONMENT=dev

status: ## Show deployment status
	@echo "Checking deployment status..."
	@helm list -n $(NAMESPACE)
	@echo ""
	@kubectl get all -n $(NAMESPACE)

logs: ## Show logs for all pods
	@echo "Showing logs for database pods..."
	@kubectl logs -n $(NAMESPACE) -l tier=database --tail=100 || true
	@kubectl logs -n $(NAMESPACE) -l tier=cache --tail=100 || true
	@kubectl logs -n $(NAMESPACE) -l tier=messaging --tail=100 || true

connect: ## Show connection information
	@echo "=== Connection Information ==="
	@echo "MongoDB URLs:"
	@echo "  Cart: mongodb://cart-mongodb-headless.$(NAMESPACE).svc.cluster.local:27017/cartdb"
	@echo "  User: mongodb://user-mongodb-headless.$(NAMESPACE).svc.cluster.local:27017/userdb"
	@echo ""
	@echo "PostgreSQL URLs:"
	@echo "  Product: product-postgres-service.$(NAMESPACE).svc.cluster.local:5432/productdb"
	@echo "  Payment: payment-postgres-service.$(NAMESPACE).svc.cluster.local:5432/paymentdb"
	@echo "  Order: order-postgres-service.$(NAMESPACE).svc.cluster.local:5432/orderdb"
	@echo "  Loyalty: loyalty-postgres-service.$(NAMESPACE).svc.cluster.local:5432/loyalty-service"
	@echo "  Shipping: shipping-postgres-service.$(NAMESPACE).svc.cluster.local:5432/shippingdb"
	@echo ""
	@echo "Redis URL:"
	@echo "  redis-service.$(NAMESPACE).svc.cluster.local:6379"
	@echo ""
	@echo "Kafka URL:"
	@echo "  kafka-service.$(NAMESPACE).svc.cluster.local:9092"