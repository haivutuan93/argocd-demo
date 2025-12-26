#!/bin/bash

# Script setup Local Docker Registry trên Kubernetes

set -e

echo "🐳 Setting up Local Docker Registry..."

# Apply registry manifests
kubectl apply -f k8s/registry/namespace.yaml
kubectl apply -f k8s/registry/pvc.yaml
kubectl apply -f k8s/registry/deployment.yaml
kubectl apply -f k8s/registry/service.yaml

# Wait for registry to be ready
echo "⏳ Waiting for Docker Registry to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/docker-registry -n docker-registry

# Get registry info
echo ""
echo "✅ Docker Registry is running!"
echo ""
echo "======================================"
echo "Local Docker Registry Info:"
echo "  Internal: docker-registry.docker-registry.svc.cluster.local:5000"
echo "  External: localhost:30500"
echo "======================================"
echo ""
echo "📝 To push images:"
echo "  docker tag argocd-demo:1.0.0 localhost:30500/argocd-demo:1.0.0"
echo "  docker push localhost:30500/argocd-demo:1.0.0"
echo ""

