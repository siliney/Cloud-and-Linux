#!/bin/bash

# System validation script for Cloud Engineer learning environment
echo "=== Cloud Engineer Environment Validation ==="

# Check essential tools
tools=("git" "docker" "kubectl" "terraform" "ansible" "aws" "curl" "jq" "python3" "node")

echo "=== Tool Availability ==="
for tool in "${tools[@]}"; do
    if command -v $tool &> /dev/null; then
        version=$(command -v $tool && $tool --version 2>/dev/null | head -1 || echo "installed")
        echo "✅ $tool: $version"
    else
        echo "❌ $tool: Not found"
    fi
done

echo ""
echo "=== Docker Status ==="
if docker ps &> /dev/null; then
    echo "✅ Docker daemon: Running"
    echo "Docker version: $(docker --version)"
else
    echo "❌ Docker daemon: Not running or permission denied"
fi

echo ""
echo "=== Kubernetes Status ==="
if kubectl version --client &> /dev/null; then
    echo "✅ kubectl: Available"
    if kubectl cluster-info &> /dev/null; then
        echo "✅ Kubernetes cluster: Connected"
    else
        echo "⚠️  Kubernetes cluster: Not connected (use minikube start)"
    fi
else
    echo "❌ kubectl: Not available"
fi

echo ""
echo "=== Cloud CLI Authentication ==="
aws sts get-caller-identity &> /dev/null && echo "✅ AWS: Authenticated" || echo "❌ AWS: Not authenticated"
az account show &> /dev/null && echo "✅ Azure: Authenticated" || echo "❌ Azure: Not authenticated"
gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null && echo "✅ GCP: Authenticated" || echo "❌ GCP: Not authenticated"

echo ""
echo "=== System Resources ==="
echo "Memory: $(free -h | grep Mem | awk '{print $2}')"
echo "Disk Space: $(df -h / | tail -1 | awk '{print $4}') available"
echo "CPU Cores: $(nproc)"

echo ""
echo "=== Validation Complete ==="
