# 🛠️ Prerequisites & Environment Setup

Complete setup guide for the Cloud Engineer + Linux Administration learning path.

## 💻 Hardware Requirements

### Minimum Requirements
- **RAM**: 8GB (16GB recommended)
- **Storage**: 50GB free space
- **CPU**: Dual-core processor
- **Internet**: Stable broadband connection

### Recommended Setup
- **RAM**: 16GB+ for running VMs and containers
- **Storage**: 100GB+ SSD for better performance
- **CPU**: Quad-core processor
- **Virtualization**: Hardware virtualization support (Intel VT-x/AMD-V)

---

## 🐧 Linux Environment Setup

### Option 1: Native Linux Installation (Recommended)
**Best for:** Complete Linux experience

**Popular Distributions:**
- **Ubuntu 22.04 LTS** - Beginner-friendly, great documentation
- **CentOS Stream 9** - Enterprise-focused, RHEL-compatible
- **Debian 12** - Stable, lightweight

**Installation:**
1. Download ISO from official website
2. Create bootable USB drive
3. Install alongside Windows (dual-boot) or replace existing OS

### Option 2: Windows Subsystem for Linux (WSL2)
**Best for:** Windows users wanting Linux experience

```powershell
# Enable WSL2
wsl --install

# Install Ubuntu
wsl --install -d Ubuntu-22.04

# Set as default
wsl --set-default Ubuntu-22.04
```

### Option 3: Virtual Machine
**Best for:** Safe learning environment

**VMware Workstation Pro / VirtualBox:**
1. Download VM software
2. Create new VM (4GB RAM, 40GB disk minimum)
3. Install Linux distribution
4. Enable virtualization features

---

## ☁️ Cloud Platform Accounts

### AWS Account Setup
1. Go to [aws.amazon.com](https://aws.amazon.com)
2. Click "Create an AWS Account"
3. Complete registration (credit card required)
4. **Important**: Set up billing alerts immediately
5. Enable MFA on root account

**Free Tier Benefits:**
- EC2: 750 hours/month t2.micro instances
- S3: 5GB storage
- RDS: 750 hours/month db.t2.micro

### Azure Account Setup
1. Visit [azure.microsoft.com](https://azure.microsoft.com)
2. Start free trial ($200 credit)
3. Complete verification
4. Set up cost management alerts

### Google Cloud Platform
1. Go to [cloud.google.com](https://cloud.google.com)
2. Start free trial ($300 credit)
3. Create first project
4. Enable billing alerts

---

## 🐳 Container & Orchestration Tools

### Docker Installation

**Ubuntu/Debian:**
```bash
# Update package index
sudo apt update

# Install dependencies
sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker $USER

# Verify installation
docker --version
docker compose version
```

**CentOS/RHEL:**
```bash
# Install Docker
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
sudo usermod -aG docker $USER
```

### Kubernetes Tools

**kubectl (Kubernetes CLI):**
```bash
# Download kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Install kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Verify installation
kubectl version --client
```

**Minikube (Local Kubernetes):**
```bash
# Download and install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Start Minikube
minikube start

# Verify installation
minikube status
```

---

## 🏗️ Infrastructure as Code Tools

### Terraform Installation
```bash
# Add HashiCorp GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add HashiCorp repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Install Terraform
sudo apt update && sudo apt install terraform

# Verify installation
terraform version
```

### Ansible Installation
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install ansible

# CentOS/RHEL
sudo yum install epel-release
sudo yum install ansible

# Verify installation
ansible --version
```

---

## 🔧 Development Tools

### Git Configuration
```bash
# Install Git (usually pre-installed)
sudo apt install git  # Ubuntu/Debian
sudo yum install git   # CentOS/RHEL

# Configure Git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global init.defaultBranch main

# Verify configuration
git config --list
```

### Text Editors & IDEs

**VS Code (Recommended):**
```bash
# Download and install VS Code
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list

sudo apt update
sudo apt install code
```

**Essential VS Code Extensions:**
- HashiCorp Terraform
- Docker
- Kubernetes
- YAML
- Remote - SSH
- GitLens

**Alternative Editors:**
- **Vim/Neovim** - Terminal-based, highly customizable
- **Nano** - Simple, beginner-friendly
- **Sublime Text** - Lightweight, fast

---

## 🌐 CLI Tools & Utilities

### AWS CLI
```bash
# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure AWS CLI
aws configure
# Enter: Access Key ID, Secret Access Key, Region, Output format

# Verify installation
aws --version
aws sts get-caller-identity
```

### Azure CLI
```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login to Azure
az login

# Verify installation
az --version
az account show
```

### Google Cloud CLI
```bash
# Install Google Cloud CLI
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# Initialize gcloud
gcloud init

# Verify installation
gcloud --version
gcloud auth list
```

### Additional Utilities
```bash
# Essential command-line tools
sudo apt install -y \
    curl \
    wget \
    jq \
    tree \
    htop \
    net-tools \
    unzip \
    zip \
    vim \
    tmux \
    screen
```

---

## 🔐 Security & Access Setup

### SSH Key Generation
```bash
# Generate SSH key pair
ssh-keygen -t ed25519 -C "your.email@example.com"

# Start SSH agent
eval "$(ssh-agent -s)"

# Add SSH key to agent
ssh-add ~/.ssh/id_ed25519

# Display public key (add to GitHub, cloud providers)
cat ~/.ssh/id_ed25519.pub
```

### GPG Key Setup (Optional)
```bash
# Generate GPG key
gpg --full-generate-key

# List GPG keys
gpg --list-secret-keys --keyid-format LONG

# Export public key
gpg --armor --export YOUR_KEY_ID
```

---

## 📊 Monitoring & Logging Tools

### Basic Monitoring Setup
```bash
# Install monitoring tools
sudo apt install -y \
    htop \
    iotop \
    nethogs \
    iftop \
    ncdu \
    glances

# Install log analysis tools
sudo apt install -y \
    logwatch \
    fail2ban \
    rsyslog
```

---

## ✅ Verification Checklist

Run these commands to verify your setup:

```bash
# System Information
uname -a
lsb_release -a

# Development Tools
git --version
code --version

# Container Tools
docker --version
docker compose version
kubectl version --client
minikube version

# Infrastructure Tools
terraform version
ansible --version

# Cloud CLIs
aws --version
az --version
gcloud --version

# Utilities
curl --version
jq --version
```

**Expected Results:**
- All commands return version information
- No "command not found" errors
- Docker runs without sudo (after logout/login)

---

## 🚀 Environment Validation

### Quick Test Script
```bash
#!/bin/bash
# Save as validate-setup.sh

echo "=== Environment Validation ==="

# Check essential tools
tools=("git" "docker" "kubectl" "terraform" "ansible" "aws" "curl" "jq")

for tool in "${tools[@]}"; do
    if command -v $tool &> /dev/null; then
        echo "✅ $tool: $(command -v $tool)"
    else
        echo "❌ $tool: Not found"
    fi
done

# Check Docker daemon
if docker ps &> /dev/null; then
    echo "✅ Docker daemon: Running"
else
    echo "❌ Docker daemon: Not running or permission denied"
fi

# Check cloud authentication
echo "=== Cloud Authentication ==="
aws sts get-caller-identity &> /dev/null && echo "✅ AWS: Authenticated" || echo "❌ AWS: Not authenticated"
az account show &> /dev/null && echo "✅ Azure: Authenticated" || echo "❌ Azure: Not authenticated"
gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null && echo "✅ GCP: Authenticated" || echo "❌ GCP: Not authenticated"

echo "=== Validation Complete ==="
```

```bash
# Make executable and run
chmod +x validate-setup.sh
./validate-setup.sh
```

---

## 🆘 Troubleshooting

### Common Issues

**Docker permission denied:**
```bash
sudo usermod -aG docker $USER
# Logout and login again
```

**kubectl not connecting to cluster:**
```bash
# For Minikube
minikube start
kubectl config use-context minikube
```

**Cloud CLI authentication issues:**
```bash
# AWS
aws configure
aws sts get-caller-identity

# Azure
az login
az account set --subscription "subscription-name"

# GCP
gcloud auth login
gcloud config set project PROJECT_ID
```

**Package installation failures:**
```bash
# Update package lists
sudo apt update

# Fix broken packages
sudo apt --fix-broken install

# Clear package cache
sudo apt clean
```

---

## 📚 Next Steps

Once your environment is set up:

1. **Validate Setup** - Run the validation script
2. **Start Learning** - Begin with [Week 1: Linux Basics](week-01-linux-basics/README.md)
3. **Join Community** - Connect with other learners
4. **Set Goals** - Define your learning objectives

**Environment ready?** Start your cloud engineering journey! 🚀
