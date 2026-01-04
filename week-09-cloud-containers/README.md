# Week 9: Cloud Container Services

## 🎯 Learning Objectives
By the end of this week, you will:
- Deploy and manage Amazon EKS clusters
- Work with Azure AKS and Google GKE
- Implement service mesh with Istio
- Apply cloud-native patterns and best practices

---

## Day 1-2: Amazon EKS (Elastic Kubernetes Service)

### EKS Setup and Management

```bash
# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Create EKS cluster
eksctl create cluster \
  --name my-cluster \
  --version 1.24 \
  --region us-west-2 \
  --nodegroup-name linux-nodes \
  --node-type m5.large \
  --nodes 3 \
  --nodes-min 1 \
  --nodes-max 4 \
  --managed

# Update kubeconfig
aws eks update-kubeconfig --region us-west-2 --name my-cluster

# Deploy sample application
kubectl apply -f https://k8s.io/examples/application/deployment.yaml
```

### 🧪 Hands-On Exercise: Day 1-2

**Exercise 1: EKS Cluster with Load Balancer**
```bash
# Create EKS cluster
eksctl create cluster --name week9-eks --region us-east-1 --nodes 2

# Deploy web application
cat > eks-webapp.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: eks-webapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: eks-webapp
  template:
    metadata:
      labels:
        app: eks-webapp
    spec:
      containers:
      - name: webapp
        image: nginx:1.20
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: eks-webapp-service
spec:
  selector:
    app: eks-webapp
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
EOF

kubectl apply -f eks-webapp.yaml

# Get load balancer URL
kubectl get services eks-webapp-service
```

---

## Day 3-4: Azure AKS & Google GKE

### Azure AKS Setup

```bash
# Create resource group
az group create --name myResourceGroup --location eastus

# Create AKS cluster
az aks create \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --node-count 2 \
  --enable-addons monitoring \
  --generate-ssh-keys

# Get credentials
az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
```

### Google GKE Setup

```bash
# Create GKE cluster
gcloud container clusters create my-gke-cluster \
  --zone us-central1-a \
  --num-nodes 3 \
  --enable-autoscaling \
  --min-nodes 1 \
  --max-nodes 5

# Get credentials
gcloud container clusters get-credentials my-gke-cluster --zone us-central1-a
```

### 🧪 Hands-On Exercise: Day 3-4

**Exercise 1: Multi-Cloud Kubernetes Comparison**
```bash
# Create comparison script
cat > multi-cloud-k8s.sh << 'EOF'
#!/bin/bash

echo "=== Multi-Cloud Kubernetes Comparison ==="

# Test EKS
if kubectl config get-contexts | grep -q eks; then
    kubectl config use-context eks-context
    echo "EKS Cluster:"
    kubectl get nodes
    echo ""
fi

# Test AKS
if kubectl config get-contexts | grep -q aks; then
    kubectl config use-context aks-context
    echo "AKS Cluster:"
    kubectl get nodes
    echo ""
fi

# Test GKE
if kubectl config get-contexts | grep -q gke; then
    kubectl config use-context gke-context
    echo "GKE Cluster:"
    kubectl get nodes
    echo ""
fi
EOF

chmod +x multi-cloud-k8s.sh
./multi-cloud-k8s.sh
```

---

## Day 5-7: Service Mesh with Istio

### Istio Installation and Configuration

```bash
# Download Istio
curl -L https://istio.io/downloadIstio | sh -
export PATH=$PWD/istio-*/bin:$PATH

# Install Istio
istioctl install --set values.defaultRevision=default

# Enable sidecar injection
kubectl label namespace default istio-injection=enabled

# Deploy sample application
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
```

### 🧪 Hands-On Exercise: Day 5-7

**Exercise 1: Istio Service Mesh Implementation**
```bash
# Install Istio
istioctl install --set values.defaultRevision=default

# Create namespace with Istio injection
kubectl create namespace istio-demo
kubectl label namespace istio-demo istio-injection=enabled

# Deploy microservices application
cat > istio-demo.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: istio-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
        version: v1
    spec:
      containers:
      - name: frontend
        image: nginx:1.20
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: frontend
  namespace: istio-demo
spec:
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: frontend-gateway
  namespace: istio-demo
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: frontend
  namespace: istio-demo
spec:
  hosts:
  - "*"
  gateways:
  - frontend-gateway
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: frontend
        port:
          number: 80
EOF

kubectl apply -f istio-demo.yaml

# Get ingress gateway URL
kubectl get svc istio-ingressgateway -n istio-system
```

---

## 🎯 Week 9 Summary & Assessment

### Skills Mastered
- ✅ **Amazon EKS** - Managed Kubernetes on AWS
- ✅ **Azure AKS** - Kubernetes service on Azure
- ✅ **Google GKE** - Google's Kubernetes engine
- ✅ **Service Mesh** - Istio for microservices communication
- ✅ **Cloud-Native Patterns** - Best practices for cloud containers

### Practice Challenges

**Challenge 1: Multi-Cloud Kubernetes**
Deploy the same application across EKS, AKS, and GKE with:
- Consistent configuration
- Cross-cloud networking
- Unified monitoring

**Challenge 2: Service Mesh Implementation**
Implement complete service mesh with:
- Traffic management
- Security policies
- Observability
- Canary deployments

### Next Steps
Ready for **Week 10: Infrastructure as Code & Automation**

---

## 📚 Additional Resources
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [AKS Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Istio Documentation](https://istio.io/latest/docs/)

**Ready for Week 10?** Continue to [Week 10: Infrastructure as Code & Automation](../week-10-infrastructure-code/README.md)
