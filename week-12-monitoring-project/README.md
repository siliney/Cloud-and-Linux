# Week 12: Monitoring, Security & Capstone Project

## 🎯 Learning Objectives
- Implement comprehensive monitoring with Prometheus and Grafana
- Set up centralized logging with ELK Stack
- Apply security best practices across the stack
- Complete a real-world capstone project

---

## Day 1-2: Monitoring with Prometheus & Grafana

### Prometheus Setup
```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']
  
  - job_name: 'application'
    static_configs:
      - targets: ['localhost:8080']
```

### Docker Compose Monitoring Stack
```yaml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana-data:/var/lib/grafana

  node-exporter:
    image: prom/node-exporter:latest
    ports:
      - "9100:9100"

volumes:
  grafana-data:
```

---

## Day 3-4: Centralized Logging with ELK Stack

### ELK Stack Setup
```yaml
version: '3.8'

services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.15.0
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ports:
      - "9200:9200"

  logstash:
    image: docker.elastic.co/logstash/logstash:7.15.0
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf
    ports:
      - "5044:5044"
    depends_on:
      - elasticsearch

  kibana:
    image: docker.elastic.co/kibana/kibana:7.15.0
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    depends_on:
      - elasticsearch
```

---

## Day 5-7: Capstone Project - Full Stack Deployment

### Project: E-commerce Platform
Deploy a complete e-commerce application with:
- **Frontend**: React application
- **Backend**: Node.js API
- **Database**: PostgreSQL
- **Cache**: Redis
- **Monitoring**: Prometheus + Grafana
- **Logging**: ELK Stack
- **CI/CD**: GitHub Actions
- **Infrastructure**: Terraform on AWS

### Project Structure
```
capstone-project/
├── frontend/           # React application
├── backend/           # Node.js API
├── database/          # PostgreSQL setup
├── infrastructure/    # Terraform configurations
├── monitoring/        # Prometheus/Grafana configs
├── logging/          # ELK Stack configs
├── .github/workflows/ # CI/CD pipelines
└── docker-compose.yml # Local development
```

### Deployment Pipeline
1. **Code Commit** → GitHub
2. **CI Pipeline** → Build, Test, Security Scan
3. **Infrastructure** → Terraform provisions AWS resources
4. **Application Deployment** → Docker containers to EKS
5. **Monitoring Setup** → Prometheus metrics collection
6. **Logging Configuration** → Centralized log aggregation
7. **Health Checks** → Automated testing and alerts

### Success Criteria
- ✅ Application accessible via HTTPS
- ✅ Auto-scaling based on load
- ✅ Monitoring dashboards functional
- ✅ Centralized logging operational
- ✅ CI/CD pipeline working
- ✅ Security best practices implemented
- ✅ Disaster recovery tested
