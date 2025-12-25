#!/bin/bash

# Script dọn dẹp tất cả resources

set -e

echo "🧹 Cleaning up all resources..."

# Xóa ArgoCD Application
echo "Deleting ArgoCD Application..."
kubectl delete application argocd-demo -n argocd --ignore-not-found=true
kubectl delete application argocd-demo-local -n argocd --ignore-not-found=true

# Xóa namespace ứng dụng
echo "Deleting application namespace..."
kubectl delete namespace argocd-demo --ignore-not-found=true

# Hỏi có muốn xóa ArgoCD không
read -p "Do you want to uninstall ArgoCD as well? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstalling ArgoCD..."
    kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml --ignore-not-found=true
    kubectl delete namespace argocd --ignore-not-found=true
fi

echo ""
echo "✅ Cleanup completed!"
echo ""

