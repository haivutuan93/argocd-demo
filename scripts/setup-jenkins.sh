#!/bin/bash

# Script setup Jenkins trên Kubernetes

set -e

echo "🔧 Setting up Jenkins on Kubernetes..."

# Apply Jenkins manifests
kubectl apply -f k8s/jenkins/namespace.yaml
kubectl apply -f k8s/jenkins/pvc.yaml
kubectl apply -f k8s/jenkins/serviceaccount.yaml
kubectl apply -f k8s/jenkins/configmap.yaml
kubectl apply -f k8s/jenkins/deployment.yaml
kubectl apply -f k8s/jenkins/service.yaml

# Wait for Jenkins to be ready
echo "⏳ Waiting for Jenkins to be ready (this may take 2-3 minutes)..."
kubectl wait --for=condition=available --timeout=300s deployment/jenkins -n jenkins

# Get initial admin password
echo ""
echo "⏳ Waiting for Jenkins to initialize..."
sleep 30

echo ""
echo "✅ Jenkins is running!"
echo ""
echo "======================================"
echo "Jenkins Access Info:"
echo "  URL: http://localhost:30800"
echo "======================================"
echo ""
echo "📝 Initial Admin Password:"
echo "   Run this command to get password:"
echo "   kubectl exec -it \$(kubectl get pods -n jenkins -l app=jenkins -o jsonpath='{.items[0].metadata.name}') -n jenkins -- cat /var/jenkins_home/secrets/initialAdminPassword"
echo ""
echo "📋 Setup Steps:"
echo "   1. Open http://localhost:30800"
echo "   2. Enter the initial admin password"
echo "   3. Install suggested plugins"
echo "   4. Create admin user"
echo "   5. Add GitHub credentials (see README)"
echo "   6. Create Pipeline job pointing to Jenkinsfile"
echo ""

