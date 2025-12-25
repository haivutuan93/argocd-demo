#!/bin/bash

# Script build Docker image

set -e

IMAGE_NAME="argocd-demo"
VERSION="${1:-1.0.0}"

echo "🐳 Building Docker image: ${IMAGE_NAME}:${VERSION}"

# Build image
docker build -t ${IMAGE_NAME}:${VERSION} -t ${IMAGE_NAME}:latest .

echo ""
echo "✅ Docker image built successfully!"
echo ""
echo "📦 Images created:"
docker images | grep ${IMAGE_NAME}
echo ""
echo "🧪 To test locally, run:"
echo "  docker run -p 8080:8080 ${IMAGE_NAME}:${VERSION}"
echo ""

