# Week 8: Kubernetes Fundamentals

## 🎯 Learning Objectives
By the end of this week, you will:
- Understand Kubernetes architecture and components
- Deploy and manage applications with Pods and Deployments
- Configure Services for networking and load balancing
- Manage configuration with ConfigMaps and Secrets
- Implement persistent storage solutions

---

## Day 1-2: Kubernetes Architecture & Setup

### Understanding Kubernetes

**What is Kubernetes?**
Kubernetes (K8s) is an open-source container orchestration platform that automates deployment, scaling, and management of containerized applications.

**Key Benefits:**
- **Automated deployment** and scaling
- **Self-healing** - restarts failed containers
- **Service discovery** and load balancing
- **Storage orchestration**
- **Secret and configuration management**

### Kubernetes Architecture

**Master Node Components:**
- **API Server** - Frontend for Kubernetes control plane
- **etcd** - Distributed key-value store for cluster data
- **Scheduler** - Assigns pods to nodes
- **Controller Manager** - Runs controller processes

**Worker Node Components:**
- **kubelet** - Node agent that manages pods
- **kube-proxy** - Network proxy for services
- **Container Runtime** - Docker, containerd, or CRI-O

### Setting Up Local Kubernetes

```bash
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Start Minikube cluster
minikube start --driver=docker

# Verify installation
kubectl cluster-info
kubectl get nodes
```

### Essential kubectl Commands

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
kubectl get services

# Apply YAML configurations
kubectl apply -f deployment.yaml
kubectl delete -f deployment.yaml
```

### 🧪 Hands-On Exercise: Day 1-2

**Exercise 1: First Kubernetes Deployment**
```bash
# Start Minikube
minikube start

# Create deployment
kubectl create deployment hello-world --image=gcr.io/google-samples/hello-app:1.0

# Check deployment status
kubectl get deployments
kubectl get pods

# Expose service
kubectl expose deployment hello-world --type=NodePort --port=8080

# Get service details
kubectl get services

# Access application
minikube service hello-world --url

# Scale deployment
kubectl scale deployment hello-world --replicas=3
kubectl get pods

# View deployment details
kubectl describe deployment hello-world
```

**Exercise 2: Working with YAML Manifests**
```bash
# Create pod manifest
cat > pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
  labels:
    app: my-app
spec:
  containers:
  - name: nginx
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
EOF

# Apply pod manifest
kubectl apply -f pod.yaml

# Check pod status
kubectl get pods
kubectl describe pod my-pod

# Port forward to access pod
kubectl port-forward my-pod 8080:80 &

# Test connection
curl http://localhost:8080

# Kill port-forward
pkill -f "kubectl port-forward"

# Delete pod
kubectl delete -f pod.yaml
```

---

## Day 3-4: Deployments & Services

### Understanding Deployments

**Deployments** manage ReplicaSets and provide declarative updates to applications:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  labels:
    app: web-app
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
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
```

### Service Types

**1. ClusterIP (Default)**
```yaml
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
```

**2. NodePort**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-nodeport
spec:
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
  type: NodePort
```

**3. LoadBalancer**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-loadbalancer
spec:
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
```

### 🧪 Hands-On Exercise: Day 3-4

**Exercise 1: Complete Web Application Deployment**
```bash
# Create deployment manifest
cat > web-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  labels:
    app: web-app
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
        volumeMounts:
        - name: web-content
          mountPath: /usr/share/nginx/html
      volumes:
      - name: web-content
        configMap:
          name: web-config
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: web-config
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head>
        <title>Kubernetes Web App</title>
    </head>
    <body>
        <h1>Hello from Kubernetes!</h1>
        <p>Pod: <span id="hostname"></span></p>
        <script>
            document.getElementById('hostname').textContent = window.location.hostname;
        </script>
    </body>
    </html>
---
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
  type: NodePort
EOF

# Apply deployment
kubectl apply -f web-deployment.yaml

# Check deployment status
kubectl get deployments
kubectl get pods
kubectl get services
kubectl get configmaps

# Access application
minikube service web-service --url

# Test load balancing
for i in {1..10}; do curl $(minikube service web-service --url); echo; done

# Update deployment (rolling update)
kubectl set image deployment/web-app web=nginx:1.21
kubectl rollout status deployment/web-app

# Check rollout history
kubectl rollout history deployment/web-app

# Rollback if needed
kubectl rollout undo deployment/web-app
```

**Exercise 2: Database with Persistent Storage**
```bash
# Create database deployment with persistent volume
cat > database.yaml << 'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:13
        env:
        - name: POSTGRES_DB
          value: mydb
        - name: POSTGRES_USER
          value: user
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: password
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
      volumes:
      - name: postgres-storage
        persistentVolumeClaim:
          claimName: postgres-pvc
---
apiVersion: v1
kind: Secret
metadata:
  name: postgres-secret
type: Opaque
data:
  password: cGFzc3dvcmQxMjM=  # base64 encoded "password123"
---
apiVersion: v1
kind: Service
metadata:
  name: postgres-service
spec:
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432
  type: ClusterIP
EOF

# Apply database configuration
kubectl apply -f database.yaml

# Check resources
kubectl get pvc
kubectl get secrets
kubectl get pods
kubectl get services

# Test database connection
kubectl exec -it deployment/postgres -- psql -U user -d mydb -c "SELECT version();"
```

---

## Day 5-7: ConfigMaps, Secrets & Storage

### ConfigMaps for Configuration Management

**Creating ConfigMaps:**
```bash
# From literal values
kubectl create configmap app-config \
  --from-literal=database_url=postgresql://localhost:5432/mydb \
  --from-literal=debug=true

# From file
echo "log_level=info" > app.properties
kubectl create configmap app-config --from-file=app.properties

# From YAML
kubectl apply -f - << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database_url: "postgresql://localhost:5432/mydb"
  debug: "true"
  app.properties: |
    log_level=info
    max_connections=100
EOF
```

### Secrets for Sensitive Data

**Creating Secrets:**
```bash
# From literal values
kubectl create secret generic app-secrets \
  --from-literal=username=admin \
  --from-literal=password=secret123

# From files
echo -n 'admin' > username.txt
echo -n 'secret123' > password.txt
kubectl create secret generic app-secrets \
  --from-file=username.txt \
  --from-file=password.txt

# TLS secrets
kubectl create secret tls tls-secret \
  --cert=path/to/cert.crt \
  --key=path/to/cert.key
```

### Persistent Volumes and Claims

**Storage Classes:**
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-ssd
  zones: us-central1-a, us-central1-b
```

**Persistent Volume:**
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-storage
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /mnt/data
```

### 🧪 Hands-On Exercise: Day 5-7

**Exercise 1: Full-Stack Application with Configuration**
```bash
# Create namespace for application
kubectl create namespace fullstack-app

# Create configuration and secrets
cat > app-config.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: fullstack-app
data:
  NODE_ENV: "production"
  PORT: "3000"
  DATABASE_HOST: "postgres-service"
  DATABASE_PORT: "5432"
  DATABASE_NAME: "webapp"
  REDIS_HOST: "redis-service"
  REDIS_PORT: "6379"
---
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
  namespace: fullstack-app
type: Opaque
data:
  DATABASE_USER: cG9zdGdyZXM=      # postgres
  DATABASE_PASSWORD: cGFzc3dvcmQ=  # password
  JWT_SECRET: bXlfc2VjcmV0X2tleQ==  # my_secret_key
EOF

kubectl apply -f app-config.yaml

# Create Redis deployment
cat > redis.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
  namespace: fullstack-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis:7-alpine
        ports:
        - containerPort: 6379
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: redis-service
  namespace: fullstack-app
spec:
  selector:
    app: redis
  ports:
  - port: 6379
    targetPort: 6379
EOF

kubectl apply -f redis.yaml

# Create PostgreSQL with persistent storage
cat > postgres.yaml << 'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
  namespace: fullstack-app
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
  namespace: fullstack-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:13
        env:
        - name: POSTGRES_DB
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: DATABASE_NAME
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: DATABASE_USER
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: DATABASE_PASSWORD
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
        resources:
          requests:
            memory: "256Mi"
            cpu: "500m"
          limits:
            memory: "512Mi"
            cpu: "1000m"
      volumes:
      - name: postgres-storage
        persistentVolumeClaim:
          claimName: postgres-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: postgres-service
  namespace: fullstack-app
spec:
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432
EOF

kubectl apply -f postgres.yaml

# Create web application
cat > webapp.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
  namespace: fullstack-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: webapp
        image: node:16-alpine
        command: ["/bin/sh"]
        args: ["-c", "npm install express pg redis && node -e \"
          const express = require('express');
          const app = express();
          const port = process.env.PORT || 3000;
          
          app.get('/', (req, res) => {
            res.json({
              message: 'Hello from Kubernetes!',
              pod: process.env.HOSTNAME,
              timestamp: new Date().toISOString()
            });
          });
          
          app.get('/health', (req, res) => {
            res.json({ status: 'healthy' });
          });
          
          app.listen(port, () => {
            console.log('Server running on port', port);
          });
        \""]
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: NODE_ENV
        - name: PORT
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: PORT
        - name: DATABASE_HOST
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: DATABASE_HOST
        - name: DATABASE_USER
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: DATABASE_USER
        - name: DATABASE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: DATABASE_PASSWORD
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          requests:
            memory: "128Mi"
            cpu: "250m"
          limits:
            memory: "256Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: webapp-service
  namespace: fullstack-app
spec:
  selector:
    app: webapp
  ports:
  - port: 80
    targetPort: 3000
  type: NodePort
EOF

kubectl apply -f webapp.yaml

# Check all resources
kubectl get all -n fullstack-app

# Test application
minikube service webapp-service -n fullstack-app --url

# Monitor pods
kubectl get pods -n fullstack-app -w
```

---

## 🎯 Week 8 Summary & Assessment

### Skills Mastered
- ✅ **Kubernetes Architecture** - Understanding master and worker components
- ✅ **Pod Management** - Creating and managing application pods
- ✅ **Deployments** - Declarative application updates and scaling
- ✅ **Services** - Network abstraction and load balancing
- ✅ **ConfigMaps & Secrets** - Configuration and sensitive data management
- ✅ **Persistent Storage** - Data persistence in containerized applications

### Key Commands Reference
```bash
# Cluster Management
kubectl cluster-info, kubectl get nodes, kubectl get namespaces

# Resource Management
kubectl apply, kubectl get, kubectl describe, kubectl delete

# Pod Operations
kubectl logs, kubectl exec, kubectl port-forward

# Scaling and Updates
kubectl scale, kubectl rollout status, kubectl rollout undo
```

### Practice Challenges

**Challenge 1: Microservices Deployment**
Deploy a complete microservices architecture:
- Frontend service (React/Vue)
- API Gateway (Nginx)
- Multiple backend services
- Database cluster (PostgreSQL)
- Message queue (Redis/RabbitMQ)

**Challenge 2: Blue-Green Deployment**
Implement blue-green deployment strategy:
- Two identical production environments
- Traffic switching mechanism
- Automated rollback capability
- Zero-downtime deployments

**Challenge 3: Monitoring and Logging**
Set up comprehensive observability:
- Prometheus for metrics
- Grafana for visualization
- ELK stack for logging
- Jaeger for distributed tracing

### Next Steps
You're ready for **Week 9: Cloud Container Services** where you'll learn:
- Amazon EKS (Elastic Kubernetes Service)
- Azure AKS (Azure Kubernetes Service)
- Google GKE (Google Kubernetes Engine)
- Service mesh with Istio

---

## 📚 Additional Resources

### Documentation
- [Kubernetes Official Documentation](https://kubernetes.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)

### Certification
- **CKA (Certified Kubernetes Administrator)** - Cluster administration
- **CKAD (Certified Kubernetes Application Developer)** - Application development
- **CKS (Certified Kubernetes Security Specialist)** - Security focus

**Ready for Week 9?** Continue to [Week 9: Cloud Container Services](../week-09-cloud-containers/README.md)
