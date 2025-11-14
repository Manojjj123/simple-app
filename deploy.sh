#!/bin/bash

# Simple deployment script for Kind cluster

set -e

echo "🚀 Starting deployment..."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="simple-app:latest"
CLUSTER_NAME="simple-app-cluster"

# Check if Kind is installed
if ! command -v kind &> /dev/null; then
    echo "❌ Kind is not installed. Please install it first."
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install it first."
    exit 1
fi

# Create Kind cluster if it doesn't exist
if ! kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
    echo -e "${BLUE}📦 Creating Kind cluster: ${CLUSTER_NAME}${NC}"
    kind create cluster --name ${CLUSTER_NAME}
else
    echo -e "${GREEN}✅ Kind cluster already exists${NC}"
fi

# Set kubectl context
kubectl cluster-info --context kind-${CLUSTER_NAME}

# Build Docker image
echo -e "${BLUE}🔨 Building Docker image...${NC}"
docker build -t ${IMAGE_NAME} .

# Load image into Kind
echo -e "${BLUE}📥 Loading image into Kind cluster...${NC}"
kind load docker-image ${IMAGE_NAME} --name ${CLUSTER_NAME}

# Deploy to Kubernetes
echo -e "${BLUE}☸️  Deploying to Kubernetes...${NC}"
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# Wait for deployment
echo -e "${BLUE}⏳ Waiting for deployment to be ready...${NC}"
kubectl wait --for=condition=available --timeout=60s deployment/simple-app

# Show status
echo -e "${GREEN}✅ Deployment successful!${NC}"
echo ""
echo "📊 Deployment Status:"
kubectl get deployments
echo ""
echo "🎯 Pods:"
kubectl get pods
echo ""
echo "🌐 Services:"
kubectl get svc simple-app
echo ""
echo -e "${GREEN}🎉 Application is ready!${NC}"
echo ""
echo "Access your application:"
echo "  1. Port forward: kubectl port-forward service/simple-app 8080:80"
echo "  2. Then visit: http://localhost:8080"
echo ""
echo "Or use NodePort (Kind specific):"
echo "  curl http://localhost:30080"
