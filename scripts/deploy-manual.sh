#!/bin/bash

# Script deploy thủ công bằng Helm (không qua ArgoCD)

set -e

RELEASE_NAME="argocd-demo"
NAMESPACE="argocd-demo"
CHART_PATH="./helm/argocd-demo"

echo "🚀 Deploying ${RELEASE_NAME} to Kubernetes..."

# Tạo namespace nếu chưa có
kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

# Deploy với Helm
helm upgrade --install ${RELEASE_NAME} ${CHART_PATH} \
  --namespace ${NAMESPACE} \
  --set image.repository=argocd-demo \
  --set image.tag=latest \
  --set image.pullPolicy=Never \
  --set replicaCount=1 \
  --set app.environment=local \
  --wait

echo ""
echo "✅ Deployment successful!"
echo ""
echo "📊 Pod status:"
kubectl get pods -n ${NAMESPACE}
echo ""
echo "🌐 Service status:"
kubectl get svc -n ${NAMESPACE}
echo ""
echo "🔗 Access the application:"
echo "  NodePort: http://localhost:30080"
echo "  Or use port-forward: kubectl port-forward svc/${RELEASE_NAME} 8080:80 -n ${NAMESPACE}"
echo ""

