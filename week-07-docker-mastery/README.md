# Week 7: Docker Mastery

## 🎯 Learning Objectives
By the end of this week, you will:
- Understand containerization concepts and benefits
- Master Docker commands and container lifecycle
- Build optimized Docker images with Dockerfile
- Implement container networking and storage
- Use Docker Compose for multi-container applications

---

## Day 1-2: Docker Fundamentals & Container Lifecycle

### Understanding Containerization

**Containers vs Virtual Machines:**
```
Virtual Machines:
Host OS → Hypervisor → Guest OS → App

Containers:
Host OS → Container Runtime → App
```

**Benefits of Containers:**
- **Lightweight** - Share OS kernel, faster startup
- **Portable** - Run anywhere Docker runs
- **Consistent** - Same environment dev to prod
- **Scalable** - Easy horizontal scaling
- **Isolated** - Process and resource isolation

### Docker Architecture

**Core Components:**
- **Docker Engine** - Container runtime
- **Docker Images** - Read-only templates
- **Docker Containers** - Running instances
- **Docker Registry** - Image storage (Docker Hub)

### Essential Docker Commands

```bash
# Container lifecycle
docker run hello-world              # Run container
docker run -it ubuntu bash          # Interactive container
docker run -d nginx                 # Detached (background)
docker ps                          # List running containers
docker ps -a                       # List all containers
docker stop container_id           # Stop container
docker start container_id          # Start stopped container
docker restart container_id       # Restart container
docker rm container_id             # Remove container
docker rm -f container_id          # Force remove running container

# Image management
docker images                      # List images
docker pull nginx:latest           # Download image
docker rmi image_id                # Remove image
docker search nginx                # Search Docker Hub
docker history image_id            # Show image layers
```

### 🧪 Hands-On Exercise: Day 1-2

**Exercise 1: Container Basics**
```bash
# Run your first container
docker run hello-world

# Run interactive Ubuntu container
docker run -it --name my-ubuntu ubuntu:20.04 bash

# Inside container, explore the environment
cat /etc/os-release
ps aux
ls /
exit

# Run web server container
docker run -d -p 8080:80 --name my-nginx nginx

# Test the web server
curl http://localhost:8080

# View container logs
docker logs my-nginx

# Execute commands in running container
docker exec -it my-nginx bash
# Inside container:
echo "<h1>Hello Docker!</h1>" > /usr/share/nginx/html/index.html
exit

# Test updated content
curl http://localhost:8080

# Stop and remove containers
docker stop my-nginx my-ubuntu
docker rm my-nginx my-ubuntu
```

**Exercise 2: Container Resource Management**
```bash
# Run container with resource limits
docker run -d --name resource-test \
    --memory=512m \
    --cpus=0.5 \
    nginx

# Monitor container resources
docker stats resource-test

# Inspect container configuration
docker inspect resource-test

# Update container resources (requires restart)
docker update --memory=1g resource-test

# Cleanup
docker stop resource-test
docker rm resource-test
```

---

## Day 3-4: Building Custom Docker Images

### Understanding Dockerfile

**Dockerfile Instructions:**
- **FROM** - Base image
- **RUN** - Execute commands during build
- **COPY/ADD** - Copy files into image
- **WORKDIR** - Set working directory
- **EXPOSE** - Document port usage
- **ENV** - Set environment variables
- **CMD** - Default command to run
- **ENTRYPOINT** - Configure container as executable

### Dockerfile Best Practices

```dockerfile
# Use specific version tags
FROM node:16-alpine

# Set working directory
WORKDIR /app

# Copy package files first (for layer caching)
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application code
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Change ownership
RUN chown -R nextjs:nodejs /app
USER nextjs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Start application
CMD ["npm", "start"]
```

### Multi-Stage Builds

```dockerfile
# Build stage
FROM node:16-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM node:16-alpine AS production
WORKDIR /app
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001
COPY --from=builder --chown=nextjs:nodejs /app/dist ./dist
COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nextjs:nodejs /app/package.json ./package.json
USER nextjs
EXPOSE 3000
CMD ["npm", "start"]
```

### 🧪 Hands-On Exercise: Day 3-4

**Exercise 1: Build Simple Web Application**
```bash
# Create project directory
mkdir docker-webapp && cd docker-webapp

# Create simple Node.js application
cat > package.json << 'EOF'
{
  "name": "docker-webapp",
  "version": "1.0.0",
  "description": "Simple Docker web app",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF

cat > server.js << 'EOF'
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
    res.json({
        message: 'Hello from Docker!',
        timestamp: new Date().toISOString(),
        hostname: require('os').hostname()
    });
});

app.get('/health', (req, res) => {
    res.status(200).json({ status: 'healthy' });
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
EOF

# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM node:16-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy application code
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S appuser -u 1001
RUN chown -R appuser:nodejs /app
USER appuser

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Start application
CMD ["npm", "start"]
EOF

# Build image
docker build -t my-webapp:v1.0 .

# Run container
docker run -d -p 3000:3000 --name webapp my-webapp:v1.0

# Test application
curl http://localhost:3000
curl http://localhost:3000/health

# Check health status
docker inspect webapp | grep -A 5 Health

# View logs
docker logs webapp

# Cleanup
docker stop webapp
docker rm webapp
```

**Exercise 2: Multi-Stage Build Optimization**
```bash
# Create optimized Dockerfile
cat > Dockerfile.optimized << 'EOF'
# Build stage
FROM node:16-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Production stage
FROM node:16-alpine AS production
WORKDIR /app

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S appuser -u 1001

# Copy dependencies and application
COPY --from=builder --chown=appuser:nodejs /app/node_modules ./node_modules
COPY --chown=appuser:nodejs . .

USER appuser
EXPOSE 3000

# Use dumb-init for proper signal handling
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server.js"]
EOF

# Build optimized image
docker build -f Dockerfile.optimized -t my-webapp:optimized .

# Compare image sizes
docker images | grep my-webapp

# Run optimized container
docker run -d -p 3001:3000 --name webapp-opt my-webapp:optimized

# Test
curl http://localhost:3001

# Cleanup
docker stop webapp-opt
docker rm webapp-opt
```

---

## Day 5-7: Docker Networking & Compose

### Docker Networking

**Network Types:**
- **bridge** - Default, isolated network
- **host** - Use host networking
- **none** - No networking
- **overlay** - Multi-host networking

```bash
# Network management
docker network ls                    # List networks
docker network create my-network     # Create custom network
docker network inspect bridge       # Inspect network
docker network rm my-network        # Remove network

# Run containers on custom network
docker network create app-network
docker run -d --name db --network app-network postgres:13
docker run -d --name web --network app-network nginx
```

### Docker Compose

**docker-compose.yml Structure:**
```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://user:pass@db:5432/mydb
    depends_on:
      - db
    volumes:
      - ./app:/app
    networks:
      - app-network

  db:
    image: postgres:13
    environment:
      POSTGRES_DB: mydb
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - app-network

volumes:
  postgres_data:

networks:
  app-network:
    driver: bridge
```

### 🧪 Hands-On Exercise: Day 5-7

**Exercise 1: Multi-Container Application**
```bash
# Create new project
mkdir docker-fullstack && cd docker-fullstack

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/webapp
    depends_on:
      - db
    volumes:
      - .:/app
      - /app/node_modules
    networks:
      - app-network

  db:
    image: postgres:13
    environment:
      POSTGRES_DB: webapp
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    networks:
      - app-network

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    networks:
      - app-network

volumes:
  postgres_data:

networks:
  app-network:
    driver: bridge
EOF

# Create enhanced application
cat > package.json << 'EOF'
{
  "name": "docker-fullstack",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.0",
    "pg": "^8.8.0",
    "redis": "^4.3.0"
  }
}
EOF

cat > server.js << 'EOF'
const express = require('express');
const { Client } = require('pg');
const redis = require('redis');

const app = express();
const PORT = process.env.PORT || 3000;

// Database connection
const dbClient = new Client({
  connectionString: process.env.DATABASE_URL
});

// Redis connection
const redisClient = redis.createClient({
  url: 'redis://redis:6379'
});

// Initialize connections
async function initializeConnections() {
  try {
    await dbClient.connect();
    await redisClient.connect();
    console.log('Connected to PostgreSQL and Redis');
    
    // Create table if not exists
    await dbClient.query(`
      CREATE TABLE IF NOT EXISTS visits (
        id SERIAL PRIMARY KEY,
        timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
  } catch (err) {
    console.error('Connection error:', err);
  }
}

app.get('/', async (req, res) => {
  try {
    // Increment visit counter in Redis
    const visits = await redisClient.incr('visits');
    
    // Log visit to PostgreSQL
    await dbClient.query('INSERT INTO visits DEFAULT VALUES');
    
    // Get total visits from database
    const result = await dbClient.query('SELECT COUNT(*) FROM visits');
    const dbVisits = result.rows[0].count;
    
    res.json({
      message: 'Hello from Docker Compose!',
      redisVisits: visits,
      dbVisits: parseInt(dbVisits),
      timestamp: new Date().toISOString()
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  initializeConnections();
});
EOF

# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM node:16-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
EOF

# Start services
docker-compose up -d

# Test application
curl http://localhost:3000
curl http://localhost:3000
curl http://localhost:3000

# View logs
docker-compose logs web
docker-compose logs db

# Scale web service
docker-compose up -d --scale web=3

# View running services
docker-compose ps

# Stop services
docker-compose down
```

**Exercise 2: Production Docker Compose**
```bash
# Create production compose file
cat > docker-compose.prod.yml << 'EOF'
version: '3.8'

services:
  web:
    build:
      context: .
      dockerfile: Dockerfile.prod
    ports:
      - "80:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://postgres:${DB_PASSWORD}@db:5432/webapp
    depends_on:
      - db
    restart: unless-stopped
    networks:
      - app-network

  db:
    image: postgres:13
    environment:
      POSTGRES_DB: webapp
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped
    networks:
      - app-network

  nginx:
    image: nginx:alpine
    ports:
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - web
    restart: unless-stopped
    networks:
      - app-network

volumes:
  postgres_data:

networks:
  app-network:
    driver: bridge
EOF

# Create production Dockerfile
cat > Dockerfile.prod << 'EOF'
FROM node:16-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:16-alpine AS production
WORKDIR /app
RUN apk add --no-cache dumb-init
RUN addgroup -g 1001 -S nodejs && adduser -S appuser -u 1001
COPY --from=builder --chown=appuser:nodejs /app/node_modules ./node_modules
COPY --chown=appuser:nodejs . .
USER appuser
EXPOSE 3000
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server.js"]
EOF

# Create environment file
cat > .env << 'EOF'
DB_PASSWORD=secure_password_123
EOF

echo "Production setup complete!"
echo "Run with: docker-compose -f docker-compose.prod.yml up -d"
```

---

## 🎯 Week 7 Summary & Assessment

### Skills Mastered
- ✅ **Container Fundamentals** - Understanding containerization vs virtualization
- ✅ **Docker Commands** - Container lifecycle management
- ✅ **Image Building** - Dockerfile creation and optimization
- ✅ **Multi-Stage Builds** - Optimized production images
- ✅ **Docker Networking** - Custom networks and service communication
- ✅ **Docker Compose** - Multi-container application orchestration

### Key Commands Reference
```bash
# Container Management
docker run, docker ps, docker stop, docker rm, docker logs, docker exec

# Image Management  
docker build, docker images, docker pull, docker push, docker rmi

# Compose Management
docker-compose up, docker-compose down, docker-compose ps, docker-compose logs
```

### Practice Challenges

**Challenge 1: Microservices Architecture**
Build a complete microservices application:
- Frontend (React/Vue)
- API Gateway (Nginx)
- User Service (Node.js)
- Product Service (Python)
- Database (PostgreSQL)
- Cache (Redis)

**Challenge 2: CI/CD Pipeline**
Create automated Docker pipeline:
- Automated testing in containers
- Multi-stage builds for optimization
- Image scanning for security
- Automated deployment

**Challenge 3: Container Monitoring**
Implement comprehensive monitoring:
- Container health checks
- Resource usage monitoring
- Log aggregation
- Performance metrics

### Next Steps
You're ready for **Week 8: Kubernetes Fundamentals** where you'll learn:
- Kubernetes architecture and components
- Pod, Service, and Deployment management
- ConfigMaps and Secrets
- Storage and networking in Kubernetes

---

## 📚 Additional Resources

### Documentation
- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Best Practices](https://docs.docker.com/develop/best-practices/)
- [Docker Compose Reference](https://docs.docker.com/compose/)

### Learning Platforms
- [Docker Classroom](https://training.docker.com/)
- [Play with Docker](https://labs.play-with-docker.com/)
- [Docker Certified Associate](https://training.mirantis.com/dca-certification-exam/)

**Ready for Week 8?** Continue to [Week 8: Kubernetes Fundamentals](../week-08-kubernetes/README.md)
