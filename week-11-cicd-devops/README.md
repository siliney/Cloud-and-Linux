# Week 11: CI/CD & DevOps Practices

## 🎯 Learning Objectives
By the end of this week, you will:
- Implement comprehensive CI/CD pipelines
- Master Git workflows and branching strategies
- Apply DevSecOps practices and security integration
- Automate testing, deployment, and monitoring

---

## Day 1-2: Advanced Git Workflows & CI Fundamentals

### Git Branching Strategies

**GitFlow Strategy:**
```bash
# Main branches
git checkout -b develop
git checkout -b feature/user-authentication
git checkout -b release/v1.2.0
git checkout -b hotfix/security-patch

# Feature development workflow
git checkout develop
git pull origin develop
git checkout -b feature/new-feature
# Make changes
git add .
git commit -m "feat: add new feature"
git push origin feature/new-feature
# Create pull request
```

**GitHub Flow (Simplified):**
```bash
# Simple workflow
git checkout main
git pull origin main
git checkout -b feature-branch
# Make changes
git push origin feature-branch
# Create pull request to main
```

### CI Pipeline Fundamentals

```yaml
# .github/workflows/ci.yml
name: Continuous Integration

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [16, 18, 20]
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run linting
        run: npm run lint
      
      - name: Run tests
        run: npm test -- --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

### 🧪 Hands-On Exercise: Day 1-2

**Exercise 1: Complete CI Pipeline Setup**
```bash
# Create sample Node.js application
mkdir cicd-demo && cd cicd-demo
npm init -y

# Install dependencies
npm install express jest eslint

# Create application
cat > app.js << 'EOF'
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({
    message: 'Hello CI/CD!',
    version: process.env.npm_package_version || '1.0.0',
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

const server = app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

module.exports = { app, server };
EOF

# Create tests
cat > app.test.js << 'EOF'
const request = require('supertest');
const { app, server } = require('./app');

describe('App', () => {
  afterAll(() => {
    server.close();
  });

  test('GET / should return welcome message', async () => {
    const response = await request(app).get('/');
    expect(response.status).toBe(200);
    expect(response.body.message).toBe('Hello CI/CD!');
  });

  test('GET /health should return healthy status', async () => {
    const response = await request(app).get('/health');
    expect(response.status).toBe(200);
    expect(response.body.status).toBe('healthy');
  });
});
EOF

# Update package.json
cat > package.json << 'EOF'
{
  "name": "cicd-demo",
  "version": "1.0.0",
  "scripts": {
    "start": "node app.js",
    "test": "jest",
    "lint": "eslint .",
    "dev": "nodemon app.js"
  },
  "dependencies": {
    "express": "^4.18.0"
  },
  "devDependencies": {
    "jest": "^29.0.0",
    "supertest": "^6.3.0",
    "eslint": "^8.0.0",
    "nodemon": "^2.0.0"
  }
}
EOF

# Create GitHub Actions workflow
mkdir -p .github/workflows
cat > .github/workflows/ci.yml << 'EOF'
name: CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run linting
        run: npm run lint
      
      - name: Run tests
        run: npm test
      
      - name: Build Docker image
        run: |
          docker build -t cicd-demo:${{ github.sha }} .
          docker tag cicd-demo:${{ github.sha }} cicd-demo:latest
EOF

# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 3000

USER node

CMD ["npm", "start"]
EOF

echo "CI pipeline setup complete!"
```

---

## Day 3-4: Advanced Pipeline Implementation

### Multi-Stage Deployment Pipeline

```yaml
# .github/workflows/deploy.yml
name: Deploy Pipeline

on:
  push:
    branches: [main]
    tags: ['v*']

jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      image-tag: ${{ steps.meta.outputs.tags }}
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Login to DockerHub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v4
        with:
          images: username/cicd-demo
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=sha
      
      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}

  deploy-staging:
    needs: build
    runs-on: ubuntu-latest
    environment: staging
    
    steps:
      - name: Deploy to staging
        run: |
          echo "Deploying ${{ needs.build.outputs.image-tag }} to staging"
          # kubectl set image deployment/app app=${{ needs.build.outputs.image-tag }}

  deploy-production:
    needs: [build, deploy-staging]
    runs-on: ubuntu-latest
    environment: production
    if: startsWith(github.ref, 'refs/tags/v')
    
    steps:
      - name: Deploy to production
        run: |
          echo "Deploying ${{ needs.build.outputs.image-tag }} to production"
          # kubectl set image deployment/app app=${{ needs.build.outputs.image-tag }}
```

### Jenkins Pipeline

```groovy
// Jenkinsfile
pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'your-registry.com'
        IMAGE_NAME = 'cicd-demo'
        KUBECONFIG = credentials('kubeconfig')
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Test') {
            steps {
                sh 'npm ci'
                sh 'npm run lint'
                sh 'npm test'
            }
            post {
                always {
                    publishTestResults testResultsPattern: 'test-results.xml'
                    publishCoverageGoberturaReports 'coverage/cobertura-coverage.xml'
                }
            }
        }
        
        stage('Build') {
            steps {
                script {
                    def image = docker.build("${IMAGE_NAME}:${BUILD_NUMBER}")
                    docker.withRegistry("https://${DOCKER_REGISTRY}", 'docker-registry-credentials') {
                        image.push()
                        image.push('latest')
                    }
                }
            }
        }
        
        stage('Deploy to Staging') {
            steps {
                sh """
                    kubectl set image deployment/app app=${DOCKER_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER} -n staging
                    kubectl rollout status deployment/app -n staging
                """
            }
        }
        
        stage('Integration Tests') {
            steps {
                sh 'npm run test:integration'
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Deploy to production?', ok: 'Deploy'
                sh """
                    kubectl set image deployment/app app=${DOCKER_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER} -n production
                    kubectl rollout status deployment/app -n production
                """
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        failure {
            emailext (
                subject: "Build Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: "Build failed. Check console output at ${env.BUILD_URL}",
                to: "${env.CHANGE_AUTHOR_EMAIL}"
            )
        }
    }
}
```

### 🧪 Hands-On Exercise: Day 3-4

**Exercise 1: Complete CD Pipeline with Kubernetes**
```bash
# Create Kubernetes manifests
mkdir -p k8s/{staging,production}

# Staging environment
cat > k8s/staging/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cicd-demo
  namespace: staging
spec:
  replicas: 2
  selector:
    matchLabels:
      app: cicd-demo
  template:
    metadata:
      labels:
        app: cicd-demo
    spec:
      containers:
      - name: app
        image: cicd-demo:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "staging"
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
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
  name: cicd-demo-service
  namespace: staging
spec:
  selector:
    app: cicd-demo
  ports:
  - port: 80
    targetPort: 3000
  type: ClusterIP
EOF

# Production environment (higher resources)
cat > k8s/production/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cicd-demo
  namespace: production
spec:
  replicas: 5
  selector:
    matchLabels:
      app: cicd-demo
  template:
    metadata:
      labels:
        app: cicd-demo
    spec:
      containers:
      - name: app
        image: cicd-demo:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "production"
        resources:
          requests:
            memory: "256Mi"
            cpu: "200m"
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
  name: cicd-demo-service
  namespace: production
spec:
  selector:
    app: cicd-demo
  ports:
  - port: 80
    targetPort: 3000
  type: LoadBalancer
EOF

# Create deployment script
cat > deploy.sh << 'EOF'
#!/bin/bash

ENVIRONMENT=${1:-staging}
IMAGE_TAG=${2:-latest}

echo "Deploying to $ENVIRONMENT with image tag $IMAGE_TAG"

# Update image tag in deployment
sed -i "s|image: cicd-demo:.*|image: cicd-demo:$IMAGE_TAG|" k8s/$ENVIRONMENT/deployment.yaml

# Apply manifests
kubectl apply -f k8s/$ENVIRONMENT/

# Wait for rollout
kubectl rollout status deployment/cicd-demo -n $ENVIRONMENT

echo "Deployment to $ENVIRONMENT complete!"
EOF

chmod +x deploy.sh
```

---

## Day 5-7: DevSecOps & Security Integration

### Security Scanning in Pipelines

```yaml
# .github/workflows/security.yml
name: Security Scan

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'
      
      - name: Upload Trivy scan results
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'
      
      - name: Run Snyk security scan
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=high
      
      - name: Docker image security scan
        run: |
          docker build -t security-test .
          docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
            aquasec/trivy image security-test
```

### Policy as Code with OPA

```rego
# policies/kubernetes.rego
package kubernetes.admission

deny[msg] {
    input.request.kind.kind == "Pod"
    input.request.object.spec.containers[_].securityContext.runAsRoot == true
    msg := "Containers must not run as root"
}

deny[msg] {
    input.request.kind.kind == "Pod"
    not input.request.object.spec.containers[_].resources.limits.memory
    msg := "Containers must have memory limits"
}

deny[msg] {
    input.request.kind.kind == "Pod"
    not input.request.object.spec.containers[_].resources.limits.cpu
    msg := "Containers must have CPU limits"
}
```

### 🧪 Hands-On Exercise: Day 5-7

**Exercise 1: Complete DevSecOps Pipeline**
```bash
# Create security-focused pipeline
cat > .github/workflows/devsecops.yml << 'EOF'
name: DevSecOps Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  security-checks:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Audit dependencies
        run: npm audit --audit-level=moderate
      
      - name: Run SAST scan
        uses: github/super-linter@v4
        env:
          DEFAULT_BRANCH: main
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          VALIDATE_JAVASCRIPT_ES: true
          VALIDATE_DOCKERFILE: true
          VALIDATE_YAML: true
      
      - name: Build Docker image
        run: docker build -t devsecops-demo:${{ github.sha }} .
      
      - name: Run container security scan
        run: |
          docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
            aquasec/trivy image devsecops-demo:${{ github.sha }}
      
      - name: Run tests with coverage
        run: |
          npm test -- --coverage --coverageReporters=lcov
      
      - name: SonarCloud Scan
        uses: SonarSource/sonarcloud-github-action@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}

  deploy:
    needs: security-checks
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy with security policies
        run: |
          # Apply OPA policies
          kubectl apply -f policies/
          
          # Deploy application
          kubectl apply -f k8s/staging/
          
          # Run security compliance check
          kubectl get pods -o json | \
            opa eval -d policies/ -I "data.kubernetes.admission.deny[x]"
EOF

# Create security policies
mkdir -p policies
cat > policies/security-policy.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: security-policies
data:
  policy.rego: |
    package kubernetes.admission
    
    deny[msg] {
        input.request.kind.kind == "Pod"
        input.request.object.spec.containers[_].securityContext.runAsRoot == true
        msg := "Containers must not run as root"
    }
    
    deny[msg] {
        input.request.kind.kind == "Pod"
        not input.request.object.spec.containers[_].resources.limits.memory
        msg := "Containers must have memory limits"
    }
    
    deny[msg] {
        input.request.kind.kind == "Pod"
        input.request.object.spec.containers[_].image
        contains(input.request.object.spec.containers[_].image, ":latest")
        msg := "Images must not use 'latest' tag"
    }
EOF

# Create secure Dockerfile
cat > Dockerfile.secure << 'EOF'
FROM node:18-alpine

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodeuser -u 1001

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# Copy application code
COPY --chown=nodeuser:nodejs . .

# Remove unnecessary packages
RUN apk del --purge

# Use non-root user
USER nodeuser

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Start application
CMD ["npm", "start"]
EOF

echo "DevSecOps pipeline setup complete!"
```

---

## 🎯 Week 11 Summary & Assessment

### Skills Mastered
- ✅ **Advanced Git Workflows** - GitFlow, GitHub Flow, branching strategies
- ✅ **CI/CD Pipelines** - GitHub Actions, Jenkins, multi-stage deployments
- ✅ **DevSecOps Integration** - Security scanning, policy as code
- ✅ **Automated Testing** - Unit tests, integration tests, security tests
- ✅ **Deployment Strategies** - Blue-green, canary, rolling deployments

### Practice Challenges

**Challenge 1: Enterprise CI/CD**
Build enterprise-grade pipeline with:
- Multi-environment promotion
- Automated testing at each stage
- Security gates and compliance
- Rollback mechanisms

**Challenge 2: GitOps Implementation**
Implement complete GitOps workflow:
- Infrastructure as code
- Application deployment automation
- Configuration drift detection
- Automated remediation

### Next Steps
Ready for **Week 12: Monitoring, Security & Capstone Project**

---

## 📚 Additional Resources
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [DevSecOps Best Practices](https://owasp.org/www-project-devsecops-guideline/)

**Ready for Week 12?** Continue to [Week 12: Monitoring, Security & Capstone Project](../week-12-monitoring-project/README.md)
