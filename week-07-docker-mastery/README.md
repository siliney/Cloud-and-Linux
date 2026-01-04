# Week 7: Docker Mastery

## 🎯 Learning Objectives
- Understand containerization concepts
- Master Docker commands and workflows
- Build custom Docker images
- Manage container networking and storage
- Use Docker Compose for multi-container applications

---

## Day 1-2: Docker Fundamentals

### What is Docker?
Docker packages applications and dependencies into lightweight, portable containers.

**Benefits:**
- **Consistency** - Same environment everywhere
- **Isolation** - Applications don't interfere
- **Portability** - Run anywhere Docker runs
- **Efficiency** - Share OS kernel, faster than VMs

### Basic Docker Commands
```bash
# Container lifecycle
docker run hello-world              # Run container
docker run -it ubuntu bash          # Interactive container
docker run -d nginx                 # Detached (background)
docker ps                          # List running containers
docker ps -a                       # List all containers
docker stop container_id           # Stop container
docker rm container_id             # Remove container

# Image management
docker images                      # List images
docker pull nginx:latest           # Download image
docker rmi image_id                # Remove image
```

### 🧪 Hands-On Exercise: Day 1-2
```bash
# Run web server container
docker run -d -p 8080:80 --name my-nginx nginx

# Test the web server
curl http://localhost:8080

# Execute commands in running container
docker exec -it my-nginx bash

# View container logs
docker logs my-nginx

# Stop and remove
docker stop my-nginx
docker rm my-nginx
```

---

## Day 3-4: Building Custom Images

### Dockerfile Basics
```dockerfile
# Use official base image
FROM ubuntu:20.04

# Set working directory
WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Copy application files
COPY . .

# Install Python dependencies
RUN pip3 install -r requirements.txt

# Expose port
EXPOSE 5000

# Define startup command
CMD ["python3", "app.py"]
```

### Building and Running Custom Images
```bash
# Build image
docker build -t my-app:v1.0 .

# Run custom image
docker run -d -p 5000:5000 my-app:v1.0

# Tag and push to registry
docker tag my-app:v1.0 username/my-app:v1.0
docker push username/my-app:v1.0
```

---

## Day 5-7: Docker Compose & Networking

### Docker Compose Example
```yaml
# docker-compose.yml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "5000:5000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/mydb
    depends_on:
      - db
    volumes:
      - ./app:/app

  db:
    image: postgres:13
    environment:
      POSTGRES_DB: mydb
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

### Docker Compose Commands
```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Scale services
docker-compose up -d --scale web=3

# Stop services
docker-compose down
```
