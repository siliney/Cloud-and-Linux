# Week 8: Kubernetes Fundamentals

## 🎯 Learning Objectives
- Understand Kubernetes architecture
- Deploy applications to Kubernetes clusters
- Manage pods, services, and deployments
- Configure storage and networking
- Implement basic monitoring and troubleshooting

---

## Day 1-2: Kubernetes Architecture

### Core Components
- **Master Node**: API Server, etcd, Scheduler, Controller Manager
- **Worker Nodes**: kubelet, kube-proxy, Container Runtime
- **Pods**: Smallest deployable units
- **Services**: Network abstraction for pods
- **Deployments**: Manage pod replicas

### Basic kubectl Commands
```bash
# Cluster information
kubectl cluster-info
kubectl get nodes
kubectl get namespaces

# Pod management
kubectl get pods
kubectl get pods -o wide
kubectl describe pod pod-name
kubectl logs pod-name
kubectl exec -it pod-name -- bash

# Create resources
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort
```

### 🧪 Hands-On Exercise: Day 1-2
```bash
# Start Minikube
minikube start

# Deploy application
kubectl create deployment hello-world --image=gcr.io/google-samples/hello-app:1.0

# Expose service
kubectl expose deployment hello-world --type=NodePort --port=8080

# Access application
minikube service hello-world --url
```

---

## Day 3-4: Deployments & Services

### Deployment YAML
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: web
        image: nginx:1.20
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
```

### Service Types
```yaml
# ClusterIP (internal)
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP

---
# LoadBalancer (external)
apiVersion: v1
kind: Service
metadata:
  name: web-lb
spec:
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
```

---

## Day 5-7: Storage & Configuration

### ConfigMaps and Secrets
```yaml
# ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database_url: "postgresql://localhost:5432/mydb"
  debug: "true"

---
# Secret
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
data:
  username: YWRtaW4=  # base64 encoded
  password: cGFzc3dvcmQ=  # base64 encoded
```

### Persistent Volumes
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: web-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```
