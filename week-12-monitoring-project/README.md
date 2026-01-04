# Week 12: Monitoring, Security & Capstone Project

## 🎯 Learning Objectives
By the end of this week, you will:
- Implement comprehensive monitoring with Prometheus and Grafana
- Set up centralized logging with ELK Stack
- Apply security best practices across the entire stack
- Complete a real-world capstone project demonstrating all skills

---

## Day 1-2: Monitoring & Observability

### Prometheus & Grafana Stack

```yaml
# docker-compose.monitoring.yml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin123
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning
    depends_on:
      - prometheus

  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    ports:
      - "9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/rootfs'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'

  alertmanager:
    image: prom/alertmanager:latest
    container_name: alertmanager
    ports:
      - "9093:9093"
    volumes:
      - ./alertmanager.yml:/etc/alertmanager/alertmanager.yml
      - alertmanager_data:/alertmanager

volumes:
  prometheus_data:
  grafana_data:
  alertmanager_data:
```

### Prometheus Configuration

```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'application'
    static_configs:
      - targets: ['app:3000']
    metrics_path: '/metrics'
    scrape_interval: 5s

  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
```

### 🧪 Hands-On Exercise: Day 1-2

**Exercise 1: Complete Monitoring Stack**
```bash
# Create monitoring directory structure
mkdir -p monitoring/{prometheus,grafana/provisioning/{dashboards,datasources},alertmanager}

# Create Prometheus configuration
cat > monitoring/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'application'
    static_configs:
      - targets: ['app:3000']
    metrics_path: '/metrics'
EOF

# Create alert rules
cat > monitoring/prometheus/alert_rules.yml << 'EOF'
groups:
  - name: system_alerts
    rules:
      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected"
          description: "CPU usage is above 80% for more than 2 minutes"

      - alert: HighMemoryUsage
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 85
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage detected"
          description: "Memory usage is above 85% for more than 2 minutes"

      - alert: ApplicationDown
        expr: up{job="application"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Application is down"
          description: "Application has been down for more than 1 minute"
EOF

# Create Grafana datasource
cat > monitoring/grafana/provisioning/datasources/prometheus.yml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
EOF

# Create Grafana dashboard
cat > monitoring/grafana/provisioning/dashboards/dashboard.yml << 'EOF'
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    options:
      path: /etc/grafana/provisioning/dashboards
EOF

# Create system dashboard
cat > monitoring/grafana/provisioning/dashboards/system-dashboard.json << 'EOF'
{
  "dashboard": {
    "id": null,
    "title": "System Monitoring",
    "tags": ["system"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "CPU Usage",
        "type": "stat",
        "targets": [
          {
            "expr": "100 - (avg by(instance) (irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
            "legendFormat": "CPU Usage %"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "percent",
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 70},
                {"color": "red", "value": 90}
              ]
            }
          }
        },
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0}
      },
      {
        "id": 2,
        "title": "Memory Usage",
        "type": "stat",
        "targets": [
          {
            "expr": "(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100",
            "legendFormat": "Memory Usage %"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "percent",
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 70},
                {"color": "red", "value": 90}
              ]
            }
          }
        },
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0}
      }
    ],
    "time": {"from": "now-1h", "to": "now"},
    "refresh": "5s"
  }
}
EOF

# Create Alertmanager configuration
cat > monitoring/alertmanager/alertmanager.yml << 'EOF'
global:
  smtp_smarthost: 'localhost:587'
  smtp_from: 'alerts@company.com'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'

receivers:
  - name: 'web.hook'
    email_configs:
      - to: 'admin@company.com'
        subject: 'Alert: {{ .GroupLabels.alertname }}'
        body: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}

inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']
EOF

# Start monitoring stack
docker-compose -f monitoring/docker-compose.yml up -d

echo "Monitoring stack deployed!"
echo "Prometheus: http://localhost:9090"
echo "Grafana: http://localhost:3000 (admin/admin123)"
echo "Alertmanager: http://localhost:9093"
```

---

## Day 3-4: Centralized Logging with ELK Stack

### ELK Stack Setup

```yaml
# docker-compose.elk.yml
version: '3.8'

services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.5.0
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
      - xpack.security.enabled=false
    ports:
      - "9200:9200"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data

  logstash:
    image: docker.elastic.co/logstash/logstash:8.5.0
    container_name: logstash
    volumes:
      - ./logstash/pipeline:/usr/share/logstash/pipeline
      - ./logstash/config:/usr/share/logstash/config
    ports:
      - "5044:5044"
      - "9600:9600"
    depends_on:
      - elasticsearch

  kibana:
    image: docker.elastic.co/kibana/kibana:8.5.0
    container_name: kibana
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    depends_on:
      - elasticsearch

  filebeat:
    image: docker.elastic.co/beats/filebeat:8.5.0
    container_name: filebeat
    user: root
    volumes:
      - ./filebeat/filebeat.yml:/usr/share/filebeat/filebeat.yml:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
    depends_on:
      - logstash

volumes:
  elasticsearch_data:
```

### 🧪 Hands-On Exercise: Day 3-4

**Exercise 1: Complete Logging Pipeline**
```bash
# Create ELK configuration
mkdir -p elk/{logstash/{pipeline,config},filebeat,kibana}

# Logstash pipeline configuration
cat > elk/logstash/pipeline/logstash.conf << 'EOF'
input {
  beats {
    port => 5044
  }
}

filter {
  if [fields][log_type] == "application" {
    json {
      source => "message"
    }
    
    date {
      match => [ "timestamp", "ISO8601" ]
    }
    
    mutate {
      add_field => { "log_level" => "%{level}" }
    }
  }
  
  if [fields][log_type] == "nginx" {
    grok {
      match => { 
        "message" => "%{NGINXACCESS}" 
      }
    }
    
    date {
      match => [ "timestamp", "dd/MMM/yyyy:HH:mm:ss Z" ]
    }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "logs-%{[fields][log_type]}-%{+YYYY.MM.dd}"
  }
  
  stdout {
    codec => rubydebug
  }
}
EOF

# Filebeat configuration
cat > elk/filebeat/filebeat.yml << 'EOF'
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/application/*.log
  fields:
    log_type: application
  fields_under_root: true

- type: log
  enabled: true
  paths:
    - /var/log/nginx/access.log
  fields:
    log_type: nginx
  fields_under_root: true

- type: docker
  containers.ids:
    - "*"
  processors:
    - add_docker_metadata:
        host: "unix:///var/run/docker.sock"

output.logstash:
  hosts: ["logstash:5044"]

logging.level: info
logging.to_files: true
logging.files:
  path: /var/log/filebeat
  name: filebeat
  keepfiles: 7
  permissions: 0644
EOF

# Create sample application with logging
cat > elk/sample-app.js << 'EOF'
const express = require('express');
const winston = require('winston');

// Configure logger
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: '/var/log/application/app.log' }),
    new winston.transports.Console()
  ]
});

const app = express();
const port = 3000;

// Middleware for request logging
app.use((req, res, next) => {
  logger.info({
    method: req.method,
    url: req.url,
    ip: req.ip,
    userAgent: req.get('User-Agent')
  });
  next();
});

app.get('/', (req, res) => {
  logger.info('Home page accessed');
  res.json({
    message: 'Hello ELK Stack!',
    timestamp: new Date().toISOString()
  });
});

app.get('/error', (req, res) => {
  logger.error('Intentional error triggered');
  res.status(500).json({ error: 'Something went wrong!' });
});

app.listen(port, () => {
  logger.info(`Server started on port ${port}`);
});
EOF

echo "ELK Stack configuration created!"
echo "Start with: docker-compose -f elk/docker-compose.elk.yml up -d"
echo "Kibana: http://localhost:5601"
```

---

## Day 5-7: Capstone Project - Complete E-commerce Platform

### Project Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   API Gateway   │    │   Microservices │
│   (React)       │───▶│   (Nginx)       │───▶│   (Node.js)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                        │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Database      │    │   Cache         │    │   Message Queue │
│   (PostgreSQL)  │    │   (Redis)       │    │   (RabbitMQ)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Monitoring    │    │   Logging       │    │   CI/CD         │
│   (Prometheus)  │    │   (ELK Stack)   │    │   (GitHub)      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 🧪 Hands-On Exercise: Day 5-7

**Exercise 1: Complete Capstone Project**
```bash
# Create project structure
mkdir -p capstone-project/{frontend,backend,infrastructure,monitoring,ci-cd}

# Backend microservice
cat > capstone-project/backend/package.json << 'EOF'
{
  "name": "ecommerce-api",
  "version": "1.0.0",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js",
    "test": "jest"
  },
  "dependencies": {
    "express": "^4.18.0",
    "pg": "^8.8.0",
    "redis": "^4.3.0",
    "bcrypt": "^5.1.0",
    "jsonwebtoken": "^8.5.1",
    "helmet": "^6.0.0",
    "cors": "^2.8.5",
    "express-rate-limit": "^6.6.0",
    "prom-client": "^14.1.0"
  },
  "devDependencies": {
    "jest": "^29.0.0",
    "supertest": "^6.3.0",
    "nodemon": "^2.0.0"
  }
}
EOF

# Backend server with monitoring
cat > capstone-project/backend/server.js << 'EOF'
const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const client = require('prom-client');

const app = express();
const port = process.env.PORT || 3000;

// Prometheus metrics
const register = new client.Registry();
client.collectDefaultMetrics({ register });

const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.5, 1, 2, 5]
});

const httpRequestsTotal = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});

register.registerMetric(httpRequestDuration);
register.registerMetric(httpRequestsTotal);

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
app.use(limiter);

// Metrics middleware
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const route = req.route ? req.route.path : req.path;
    
    httpRequestDuration
      .labels(req.method, route, res.statusCode)
      .observe(duration);
    
    httpRequestsTotal
      .labels(req.method, route, res.statusCode)
      .inc();
  });
  
  next();
});

// Routes
app.get('/', (req, res) => {
  res.json({
    service: 'E-commerce API',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Products API
app.get('/api/products', (req, res) => {
  res.json([
    { id: 1, name: 'Laptop', price: 999.99 },
    { id: 2, name: 'Phone', price: 599.99 },
    { id: 3, name: 'Tablet', price: 399.99 }
  ]);
});

app.listen(port, () => {
  console.log(`E-commerce API running on port ${port}`);
});

module.exports = app;
EOF

# Kubernetes deployment
cat > capstone-project/infrastructure/k8s-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecommerce-api
  labels:
    app: ecommerce-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: ecommerce-api
  template:
    metadata:
      labels:
        app: ecommerce-api
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "3000"
        prometheus.io/path: "/metrics"
    spec:
      containers:
      - name: api
        image: ecommerce-api:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "production"
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: url
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
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
---
apiVersion: v1
kind: Service
metadata:
  name: ecommerce-api-service
  labels:
    app: ecommerce-api
spec:
  selector:
    app: ecommerce-api
  ports:
  - port: 80
    targetPort: 3000
  type: ClusterIP
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ecommerce-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: ecommerce.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: ecommerce-api-service
            port:
              number: 80
EOF

# CI/CD Pipeline
cat > capstone-project/ci-cd/.github/workflows/deploy.yml << 'EOF'
name: Deploy E-commerce Platform

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
        working-directory: backend
      - run: npm test
        working-directory: backend

  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'

  build-and-deploy:
    needs: [test, security-scan]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build Docker image
        run: |
          docker build -t ecommerce-api:${{ github.sha }} backend/
          docker tag ecommerce-api:${{ github.sha }} ecommerce-api:latest
      
      - name: Deploy to Kubernetes
        run: |
          kubectl apply -f infrastructure/k8s-deployment.yaml
          kubectl set image deployment/ecommerce-api api=ecommerce-api:${{ github.sha }}
          kubectl rollout status deployment/ecommerce-api
EOF

echo "Capstone project structure created!"
echo "This demonstrates:"
echo "- Microservices architecture"
echo "- Kubernetes deployment"
echo "- Monitoring with Prometheus"
echo "- CI/CD with GitHub Actions"
echo "- Security scanning"
echo "- Production-ready configuration"
```

---

## 🎯 Week 12 Summary & Final Assessment

### Skills Mastered
- ✅ **Comprehensive Monitoring** - Prometheus, Grafana, alerting
- ✅ **Centralized Logging** - ELK Stack, log aggregation
- ✅ **Security Implementation** - Scanning, policies, compliance
- ✅ **Production Deployment** - Complete application stack
- ✅ **End-to-End Automation** - CI/CD, monitoring, logging

### Capstone Project Deliverables
- ✅ **Multi-tier Application** - Frontend, backend, database
- ✅ **Container Orchestration** - Kubernetes deployment
- ✅ **Infrastructure as Code** - Terraform configurations
- ✅ **CI/CD Pipeline** - Automated testing and deployment
- ✅ **Monitoring & Logging** - Complete observability stack
- ✅ **Security Integration** - Scanning and compliance
- ✅ **Documentation** - Architecture and deployment guides

### Career Readiness Assessment
- ✅ **Technical Skills** - Cloud engineering proficiency
- ✅ **Practical Experience** - Real-world project portfolio
- ✅ **Best Practices** - Industry-standard implementations
- ✅ **Problem Solving** - Troubleshooting and optimization
- ✅ **Communication** - Documentation and presentation

---

## 🎓 Congratulations!

You have successfully completed the **Cloud Engineer + Linux Administration** learning path! You now possess:

### **Professional Skills:**
- Linux system administration expertise
- Multi-cloud platform proficiency (AWS, Azure, GCP)
- Container technologies mastery (Docker, Kubernetes)
- Infrastructure as Code implementation
- CI/CD pipeline development
- Monitoring and security best practices

### **Career Opportunities:**
- **Cloud Engineer** - $80,000-$120,000
- **DevOps Engineer** - $90,000-$130,000
- **Site Reliability Engineer** - $100,000-$150,000
- **Platform Engineer** - $110,000-$160,000
- **Cloud Architect** - $120,000-$180,000

### **Next Steps:**
1. **Update Resume** - Highlight new skills and capstone project
2. **LinkedIn Profile** - Showcase certifications and experience
3. **GitHub Portfolio** - Document and share your projects
4. **Apply for Positions** - Target roles matching your expertise
5. **Continue Learning** - Stay current with cloud technologies

---

## 📚 Additional Resources

### Certification Paths
- **AWS Solutions Architect Associate**
- **Certified Kubernetes Administrator (CKA)**
- **Terraform Associate**
- **Linux Professional Institute (LPIC)**

### Community & Networking
- **Cloud Native Computing Foundation (CNCF)**
- **AWS User Groups**
- **DevOps meetups and conferences**
- **Open source contributions**

**Congratulations on your cloud engineering journey!** 🚀☁️
