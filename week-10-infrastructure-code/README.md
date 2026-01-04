# Week 10: Infrastructure as Code & Automation

## 🎯 Learning Objectives
By the end of this week, you will:
- Master Terraform for infrastructure provisioning
- Implement Ansible for configuration management
- Apply GitOps principles and workflows
- Automate infrastructure deployment pipelines

---

## Day 1-2: Advanced Terraform

### Terraform State Management

```bash
# Remote state with S3 backend
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

# Initialize with remote backend
terraform init

# Workspace management
terraform workspace new production
terraform workspace new staging
terraform workspace select production
```

### Terraform Modules

```hcl
# modules/vpc/main.tf
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main-vpc"
  }
}

output "vpc_id" {
  value = aws_vpc.main.id
}
```

### 🧪 Hands-On Exercise: Day 1-2

**Exercise 1: Complete Infrastructure with Terraform**
```bash
# Create main Terraform configuration
cat > main.tf << 'EOF'
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  
  tags = local.common_tags
}

# EKS Module
module "eks" {
  source = "./modules/eks"
  
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids
  
  tags = local.common_tags
}

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}
EOF

# Create variables file
cat > variables.tf << 'EOF'
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "week10-project"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "week10-cluster"
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.24"
}
EOF

# Initialize and plan
terraform init
terraform plan
```

---

## Day 3-4: Ansible Configuration Management

### Ansible Playbooks

```yaml
# playbook.yml
---
- name: Configure web servers
  hosts: webservers
  become: yes
  vars:
    nginx_port: 80
    app_user: webapp
  
  tasks:
    - name: Install nginx
      package:
        name: nginx
        state: present
    
    - name: Create application user
      user:
        name: "{{ app_user }}"
        system: yes
        shell: /bin/false
    
    - name: Configure nginx
      template:
        src: nginx.conf.j2
        dest: /etc/nginx/nginx.conf
        backup: yes
      notify: restart nginx
    
    - name: Start and enable nginx
      service:
        name: nginx
        state: started
        enabled: yes
  
  handlers:
    - name: restart nginx
      service:
        name: nginx
        state: restarted
```

### Ansible Roles

```bash
# Create role structure
ansible-galaxy init webserver

# roles/webserver/tasks/main.yml
---
- name: Install packages
  package:
    name: "{{ item }}"
    state: present
  loop:
    - nginx
    - certbot
    - python3-certbot-nginx

- name: Configure firewall
  ufw:
    rule: allow
    port: "{{ item }}"
  loop:
    - "22"
    - "80"
    - "443"
```

### 🧪 Hands-On Exercise: Day 3-4

**Exercise 1: Ansible Infrastructure Configuration**
```bash
# Create inventory file
cat > inventory.ini << 'EOF'
[webservers]
web1 ansible_host=10.0.1.10
web2 ansible_host=10.0.1.11

[databases]
db1 ansible_host=10.0.2.10

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_rsa
EOF

# Create comprehensive playbook
cat > site.yml << 'EOF'
---
- name: Configure all servers
  hosts: all
  become: yes
  tasks:
    - name: Update package cache
      apt:
        update_cache: yes
        cache_valid_time: 3600
    
    - name: Install common packages
      apt:
        name:
          - htop
          - vim
          - curl
          - wget
          - unzip
        state: present
    
    - name: Configure timezone
      timezone:
        name: UTC

- name: Configure web servers
  hosts: webservers
  become: yes
  vars:
    nginx_sites:
      - name: default
        port: 80
        root: /var/www/html
  
  tasks:
    - name: Install nginx
      apt:
        name: nginx
        state: present
    
    - name: Create web content
      copy:
        content: |
          <!DOCTYPE html>
          <html>
          <head><title>Ansible Managed Server</title></head>
          <body>
            <h1>Hello from {{ inventory_hostname }}!</h1>
            <p>Configured by Ansible on {{ ansible_date_time.iso8601 }}</p>
          </body>
          </html>
        dest: /var/www/html/index.html
        owner: www-data
        group: www-data
        mode: '0644'
    
    - name: Start nginx
      service:
        name: nginx
        state: started
        enabled: yes

- name: Configure database servers
  hosts: databases
  become: yes
  tasks:
    - name: Install PostgreSQL
      apt:
        name:
          - postgresql
          - postgresql-contrib
          - python3-psycopg2
        state: present
    
    - name: Start PostgreSQL
      service:
        name: postgresql
        state: started
        enabled: yes
EOF

# Run playbook
ansible-playbook -i inventory.ini site.yml
```

---

## Day 5-7: GitOps & Automation Pipelines

### GitOps with ArgoCD

```yaml
# argocd-application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/username/my-app-config
    targetRevision: HEAD
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: my-app
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### Infrastructure Pipeline

```yaml
# .github/workflows/infrastructure.yml
name: Infrastructure Pipeline

on:
  push:
    branches: [main]
    paths: ['infrastructure/**']

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0
      
      - name: Terraform Init
        run: terraform init
        working-directory: infrastructure
      
      - name: Terraform Plan
        run: terraform plan
        working-directory: infrastructure
      
      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve
        working-directory: infrastructure
```

### 🧪 Hands-On Exercise: Day 5-7

**Exercise 1: Complete GitOps Pipeline**
```bash
# Create GitOps repository structure
mkdir -p gitops-demo/{infrastructure,applications,configs}

# Create Terraform infrastructure
cat > gitops-demo/infrastructure/main.tf << 'EOF'
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_namespace" "applications" {
  metadata {
    name = "applications"
  }
}
EOF

# Create application manifests
cat > gitops-demo/applications/webapp.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
  namespace: applications
spec:
  replicas: 3
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
        image: nginx:1.20
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: webapp-service
  namespace: applications
spec:
  selector:
    app: webapp
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

# Create ArgoCD application
cat > gitops-demo/configs/argocd-app.yaml << 'EOF'
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: webapp
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/username/gitops-demo
    targetRevision: HEAD
    path: applications
  destination:
    server: https://kubernetes.default.svc
    namespace: applications
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOF

echo "GitOps structure created!"
echo "Initialize git repository and push to GitHub to complete setup"
```

---

## 🎯 Week 10 Summary & Assessment

### Skills Mastered
- ✅ **Advanced Terraform** - Modules, state management, workspaces
- ✅ **Ansible Automation** - Playbooks, roles, inventory management
- ✅ **GitOps Principles** - Declarative infrastructure management
- ✅ **CI/CD Pipelines** - Automated infrastructure deployment
- ✅ **Infrastructure Testing** - Validation and compliance

### Practice Challenges

**Challenge 1: Multi-Environment Infrastructure**
Create infrastructure for:
- Development environment
- Staging environment  
- Production environment
- Automated promotion pipeline

**Challenge 2: Compliance as Code**
Implement:
- Security policy enforcement
- Cost optimization rules
- Resource tagging standards
- Automated compliance reporting

### Next Steps
Ready for **Week 11: CI/CD & DevOps Practices**

---

## 📚 Additional Resources
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [GitOps Principles](https://www.gitops.tech/)

**Ready for Week 11?** Continue to [Week 11: CI/CD & DevOps Practices](../week-11-cicd-devops/README.md)
