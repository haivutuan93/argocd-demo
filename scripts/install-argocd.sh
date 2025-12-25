#!/bin/bash

# Script cài đặt ArgoCD trên Kubernetes (Docker Desktop)

set -e

echo "🚀 Installing ArgoCD on Kubernetes..."

# Tạo namespace cho ArgoCD
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Cài đặt ArgoCD
echo "📦 Applying ArgoCD manifests..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Chờ ArgoCD sẵn sàng
echo "⏳ Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Lấy password admin
echo ""
echo "✅ ArgoCD installed successfully!"
echo ""
echo "📝 Getting admin password..."
ADMIN_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo ""
echo "======================================"
echo "ArgoCD Admin Credentials:"
echo "  Username: admin"
echo "  Password: $ADMIN_PASSWORD"
echo "======================================"
echo ""

# Port-forward instructions
echo "🌐 To access ArgoCD UI, run:"
echo "  kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""
echo "Then open: https://localhost:8080"
echo ""

