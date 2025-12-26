#!/bin/bash

# Local CI/CD Script - Simulate GitHub Actions locally
# Sử dụng Local Docker Registry

set -e

REGISTRY="localhost:30500"
IMAGE_NAME="argocd-demo"
VERSION="${1:-$(date +%Y%m%d%H%M%S)-$(git rev-parse --short HEAD 2>/dev/null || echo 'local')}"

echo "🚀 Local CI/CD Pipeline"
echo "========================"
echo "Registry: $REGISTRY"
echo "Image: $IMAGE_NAME"
echo "Version: $VERSION"
echo ""

# Step 1: Build Docker image
echo "📦 Step 1: Building Docker image..."
docker build -t ${IMAGE_NAME}:${VERSION} -t ${IMAGE_NAME}:latest .

# Step 2: Tag for local registry
echo "🏷️  Step 2: Tagging for local registry..."
docker tag ${IMAGE_NAME}:${VERSION} ${REGISTRY}/${IMAGE_NAME}:${VERSION}
docker tag ${IMAGE_NAME}:latest ${REGISTRY}/${IMAGE_NAME}:latest

# Step 3: Push to local registry
echo "⬆️  Step 3: Pushing to local registry..."
docker push ${REGISTRY}/${IMAGE_NAME}:${VERSION}
docker push ${REGISTRY}/${IMAGE_NAME}:latest

# Step 4: Update Helm values
echo "📝 Step 4: Updating Helm values..."
sed -i.bak "s|tag: \".*\"|tag: \"${VERSION}\"|g" helm/argocd-demo/values.yaml
sed -i.bak "s|repository: .*|repository: ${REGISTRY}/${IMAGE_NAME}|g" helm/argocd-demo/values.yaml
rm -f helm/argocd-demo/values.yaml.bak

echo ""
echo "✅ Local CI/CD Complete!"
echo ""
echo "======================================"
echo "Image: ${REGISTRY}/${IMAGE_NAME}:${VERSION}"
echo "======================================"
echo ""
echo "📋 Next steps:"
echo "  1. Commit and push changes to GitHub:"
echo "     git add ."
echo "     git commit -m '🚀 Update image to ${VERSION}'"
echo "     git push"
echo ""
echo "  2. ArgoCD will auto-sync (or manual sync):"
echo "     kubectl patch application argocd-demo -n argocd --type merge -p '{\"metadata\": {\"annotations\": {\"argocd.argoproj.io/refresh\": \"hard\"}}}'"
echo ""

