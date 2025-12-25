#!/bin/bash

# Script deploy ứng dụng qua ArgoCD

set -e

echo "🚀 Deploying application via ArgoCD..."

# Kiểm tra ArgoCD đã cài đặt chưa
if ! kubectl get namespace argocd &> /dev/null; then
    echo "❌ ArgoCD is not installed. Please run ./scripts/install-argocd.sh first."
    exit 1
fi

# Tạo namespace cho ứng dụng
kubectl create namespace argocd-demo --dry-run=client -o yaml | kubectl apply -f -

# Apply ArgoCD Application
echo "📦 Applying ArgoCD Application..."
kubectl apply -f ./argocd/application.yaml

echo ""
echo "✅ ArgoCD Application created!"
echo ""
echo "📊 Check sync status:"
echo "  kubectl get application argocd-demo -n argocd"
echo ""
echo "🌐 Or check in ArgoCD UI:"
echo "  kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "  Then open: https://localhost:8080"
echo ""

