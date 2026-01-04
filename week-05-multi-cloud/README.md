# Week 5: Multi-Cloud & Azure/GCP Basics

## 🎯 Learning Objectives
By the end of this week, you will:
- Understand multi-cloud strategies and benefits
- Set up Azure and GCP accounts with proper security
- Deploy basic resources in Azure and GCP
- Compare services across AWS, Azure, and GCP
- Implement cross-cloud architecture patterns

---

## Day 1-2: Azure Fundamentals

### Understanding Microsoft Azure

Azure is Microsoft's cloud platform with over 200 services. Key concepts:

**Azure Hierarchy:**
```
Management Groups
└── Subscriptions
    └── Resource Groups
        └── Resources (VMs, Storage, etc.)
```

**Core Azure Services:**
- **Compute**: Virtual Machines, App Service, Functions
- **Storage**: Blob Storage, File Storage, Disk Storage
- **Networking**: Virtual Network, Load Balancer, Application Gateway
- **Databases**: SQL Database, Cosmos DB, MySQL

### Azure Account Setup

**Step 1: Create Azure Account**
1. Go to azure.microsoft.com
2. Start free trial ($200 credit for 30 days)
3. Complete phone and credit card verification
4. Access Azure Portal

**Step 2: Azure CLI Setup**
```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login to Azure
az login

# List subscriptions
az account list --output table

# Set default subscription
az account set --subscription "Your Subscription Name"

# Verify login
az account show
```

### Azure Resource Groups and Regions

**Resource Groups** are logical containers for Azure resources:
```bash
# Create resource group
az group create --name myResourceGroup --location eastus

# List resource groups
az group list --output table

# Show resource group details
az group show --name myResourceGroup
```

**Azure Regions:**
- **East US** (Virginia) - Primary US region
- **West Europe** (Netherlands) - Primary European region
- **Southeast Asia** (Singapore) - Primary Asian region

### 🧪 Hands-On Exercise: Day 1-2

**Exercise 1: Azure Virtual Machine Deployment**
```bash
# Create resource group
az group create --name week5-azure-lab --location eastus

# Create virtual network
az network vnet create \
    --resource-group week5-azure-lab \
    --name myVNet \
    --address-prefix 10.0.0.0/16 \
    --subnet-name mySubnet \
    --subnet-prefix 10.0.1.0/24

# Create public IP
az network public-ip create \
    --resource-group week5-azure-lab \
    --name myPublicIP \
    --allocation-method Dynamic

# Create Network Security Group and rule
az network nsg create \
    --resource-group week5-azure-lab \
    --name myNetworkSecurityGroup

az network nsg rule create \
    --resource-group week5-azure-lab \
    --nsg-name myNetworkSecurityGroup \
    --name myNetworkSecurityGroupRuleSSH \
    --protocol tcp \
    --priority 1000 \
    --destination-port-range 22 \
    --access allow

# Create virtual NIC
az network nic create \
    --resource-group week5-azure-lab \
    --name myNic \
    --vnet-name myVNet \
    --subnet mySubnet \
    --public-ip-address myPublicIP \
    --network-security-group myNetworkSecurityGroup

# Create virtual machine
az vm create \
    --resource-group week5-azure-lab \
    --name myVM \
    --nics myNic \
    --image Ubuntu2204 \
    --size Standard_B1s \
    --admin-username azureuser \
    --generate-ssh-keys

# Get public IP address
az vm show \
    --resource-group week5-azure-lab \
    --name myVM \
    --show-details \
    --query [publicIps] \
    --output tsv
```

**Exercise 2: Azure Storage Account**
```bash
# Create storage account
az storage account create \
    --name mystorageaccount$(date +%s) \
    --resource-group week5-azure-lab \
    --location eastus \
    --sku Standard_LRS

# Get storage account key
STORAGE_KEY=$(az storage account keys list \
    --resource-group week5-azure-lab \
    --account-name mystorageaccount$(date +%s) \
    --query '[0].value' \
    --output tsv)

# Create blob container
az storage container create \
    --name mycontainer \
    --account-name mystorageaccount$(date +%s) \
    --account-key $STORAGE_KEY

# Upload file to blob storage
echo "Hello Azure Blob Storage" > azure-test.txt
az storage blob upload \
    --file azure-test.txt \
    --container-name mycontainer \
    --name azure-test.txt \
    --account-name mystorageaccount$(date +%s) \
    --account-key $STORAGE_KEY
```

---

## Day 3-4: Google Cloud Platform Basics

### Understanding Google Cloud Platform (GCP)

GCP is Google's cloud platform built on the same infrastructure that powers Google's services.

**GCP Hierarchy:**
```
Organization
└── Folders (optional)
    └── Projects
        └── Resources
```

**Core GCP Services:**
- **Compute**: Compute Engine, App Engine, Cloud Functions
- **Storage**: Cloud Storage, Persistent Disk, Filestore
- **Networking**: VPC, Cloud Load Balancing, Cloud CDN
- **Databases**: Cloud SQL, Firestore, BigQuery

### GCP Account Setup

**Step 1: Create GCP Account**
1. Go to cloud.google.com
2. Start free trial ($300 credit for 90 days)
3. Create first project
4. Enable billing (required even for free tier)

**Step 2: Google Cloud CLI Setup**
```bash
# Install Google Cloud CLI
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# Initialize gcloud
gcloud init

# Login to GCP
gcloud auth login

# Set default project
gcloud config set project YOUR_PROJECT_ID

# Set default region and zone
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-a

# Verify configuration
gcloud config list
```

### GCP Projects and IAM

**Projects** are the fundamental organizing entity in GCP:
```bash
# List projects
gcloud projects list

# Create new project
gcloud projects create my-learning-project-$(date +%s) --name="Learning Project"

# Set active project
gcloud config set project my-learning-project-$(date +%s)

# Enable required APIs
gcloud services enable compute.googleapis.com
gcloud services enable storage.googleapis.com
```

### 🧪 Hands-On Exercise: Day 3-4

**Exercise 1: GCP Compute Engine Instance**
```bash
# Create VPC network
gcloud compute networks create my-vpc --subnet-mode custom

# Create subnet
gcloud compute networks subnets create my-subnet \
    --network my-vpc \
    --range 10.0.1.0/24 \
    --region us-central1

# Create firewall rule for SSH
gcloud compute firewall-rules create allow-ssh \
    --network my-vpc \
    --allow tcp:22 \
    --source-ranges 0.0.0.0/0

# Create firewall rule for HTTP
gcloud compute firewall-rules create allow-http \
    --network my-vpc \
    --allow tcp:80 \
    --source-ranges 0.0.0.0/0 \
    --target-tags http-server

# Create Compute Engine instance
gcloud compute instances create my-instance \
    --zone us-central1-a \
    --machine-type e2-micro \
    --subnet my-subnet \
    --image-family ubuntu-2204-lts \
    --image-project ubuntu-os-cloud \
    --tags http-server \
    --metadata startup-script='#!/bin/bash
apt update
apt install -y apache2
systemctl start apache2
systemctl enable apache2
echo "<h1>Hello from GCP!</h1>" > /var/www/html/index.html'

# Get instance details
gcloud compute instances describe my-instance --zone us-central1-a

# SSH to instance
gcloud compute ssh my-instance --zone us-central1-a
```

**Exercise 2: GCP Cloud Storage**
```bash
# Create Cloud Storage bucket (globally unique name)
BUCKET_NAME="my-gcp-bucket-$(date +%s)"
gsutil mb gs://$BUCKET_NAME

# Upload file to bucket
echo "Hello Google Cloud Storage" > gcp-test.txt
gsutil cp gcp-test.txt gs://$BUCKET_NAME/

# List bucket contents
gsutil ls gs://$BUCKET_NAME/

# Make file publicly readable
gsutil acl ch -u AllUsers:R gs://$BUCKET_NAME/gcp-test.txt

# Get public URL
echo "Public URL: https://storage.googleapis.com/$BUCKET_NAME/gcp-test.txt"

# Set up website hosting
gsutil web set -m index.html -e 404.html gs://$BUCKET_NAME

# Create simple website
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>GCP Website</title></head>
<body>
    <h1>Hello from Google Cloud Storage!</h1>
    <p>This website is hosted on GCP Cloud Storage.</p>
</body>
</html>
EOF

gsutil cp index.html gs://$BUCKET_NAME/
gsutil acl ch -u AllUsers:R gs://$BUCKET_NAME/index.html
```

---

## Day 5-7: Multi-Cloud Comparison & Architecture

### Service Mapping Across Cloud Providers

| Service Category | AWS | Azure | GCP |
|-----------------|-----|-------|-----|
| **Compute** | EC2 | Virtual Machines | Compute Engine |
| **Container** | ECS/EKS | ACI/AKS | GKE |
| **Serverless** | Lambda | Functions | Cloud Functions |
| **Object Storage** | S3 | Blob Storage | Cloud Storage |
| **Database** | RDS | SQL Database | Cloud SQL |
| **NoSQL** | DynamoDB | Cosmos DB | Firestore |
| **Networking** | VPC | Virtual Network | VPC |
| **Load Balancer** | ELB/ALB | Load Balancer | Cloud Load Balancing |
| **CDN** | CloudFront | CDN | Cloud CDN |
| **DNS** | Route 53 | DNS | Cloud DNS |
| **Monitoring** | CloudWatch | Monitor | Cloud Monitoring |

### Multi-Cloud Architecture Patterns

**1. Multi-Cloud for Disaster Recovery:**
```
Primary: AWS (us-east-1)
├── Application Servers
├── Database (RDS)
└── Storage (S3)

Backup: Azure (East US)
├── Standby Servers
├── Database Replica
└── Backup Storage
```

**2. Multi-Cloud for Geographic Distribution:**
```
Americas: AWS
├── US East: Primary
└── US West: Secondary

Europe: Azure
├── West Europe: Primary
└── North Europe: Secondary

Asia: GCP
├── Asia Southeast: Primary
└── Asia East: Secondary
```

### Cost Comparison Strategies

**Compute Cost Comparison (1 vCPU, 2GB RAM):**
```bash
# AWS t3.small (us-east-1): ~$16.79/month
# Azure B1ms (East US): ~$15.33/month  
# GCP e2-small (us-central1): ~$13.07/month

# Create cost comparison script
cat > cost-comparison.sh << 'EOF'
#!/bin/bash

echo "=== Multi-Cloud Cost Comparison ==="
echo "Instance Type: 1 vCPU, 2GB RAM, Linux"
echo ""

# AWS pricing (approximate)
aws_cost=16.79
echo "AWS t3.small (us-east-1): \$${aws_cost}/month"

# Azure pricing (approximate)
azure_cost=15.33
echo "Azure B1ms (East US): \$${azure_cost}/month"

# GCP pricing (approximate)
gcp_cost=13.07
echo "GCP e2-small (us-central1): \$${gcp_cost}/month"

echo ""
echo "Savings with GCP vs AWS: \$$(echo "$aws_cost - $gcp_cost" | bc)/month"
echo "Savings with Azure vs AWS: \$$(echo "$aws_cost - $azure_cost" | bc)/month"
EOF

chmod +x cost-comparison.sh
./cost-comparison.sh
```

### 🧪 Hands-On Exercise: Day 5-7

**Exercise 1: Cross-Cloud Resource Inventory**
```bash
# Create inventory script
cat > cloud-inventory.sh << 'EOF'
#!/bin/bash

echo "=== Multi-Cloud Resource Inventory ==="
echo "Generated: $(date)"
echo ""

echo "=== AWS Resources ==="
if command -v aws &> /dev/null; then
    echo "EC2 Instances:"
    aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,State.Name,InstanceType]' --output table 2>/dev/null || echo "  No AWS credentials or instances"
    
    echo "S3 Buckets:"
    aws s3 ls 2>/dev/null || echo "  No AWS credentials or buckets"
else
    echo "  AWS CLI not installed"
fi

echo ""
echo "=== Azure Resources ==="
if command -v az &> /dev/null; then
    echo "Virtual Machines:"
    az vm list --query '[].{Name:name,State:powerState,Size:hardwareProfile.vmSize}' --output table 2>/dev/null || echo "  No Azure credentials or VMs"
    
    echo "Storage Accounts:"
    az storage account list --query '[].{Name:name,Location:location}' --output table 2>/dev/null || echo "  No Azure credentials or storage accounts"
else
    echo "  Azure CLI not installed"
fi

echo ""
echo "=== GCP Resources ==="
if command -v gcloud &> /dev/null; then
    echo "Compute Instances:"
    gcloud compute instances list --format="table(name,zone,machineType,status)" 2>/dev/null || echo "  No GCP credentials or instances"
    
    echo "Storage Buckets:"
    gsutil ls 2>/dev/null || echo "  No GCP credentials or buckets"
else
    echo "  Google Cloud CLI not installed"
fi
EOF

chmod +x cloud-inventory.sh
./cloud-inventory.sh
```

**Exercise 2: Multi-Cloud Deployment Script**
```bash
# Create multi-cloud deployment script
cat > multi-cloud-deploy.sh << 'EOF'
#!/bin/bash

RESOURCE_PREFIX="multicloud-$(date +%s)"

echo "=== Multi-Cloud Deployment ==="
echo "Resource Prefix: $RESOURCE_PREFIX"
echo ""

# Deploy to AWS
echo "Deploying to AWS..."
if command -v aws &> /dev/null && aws sts get-caller-identity &>/dev/null; then
    # Create S3 bucket
    aws s3 mb s3://${RESOURCE_PREFIX}-aws-bucket 2>/dev/null && echo "  ✅ AWS S3 bucket created"
    
    # Upload test file
    echo "AWS deployment - $(date)" > aws-test.txt
    aws s3 cp aws-test.txt s3://${RESOURCE_PREFIX}-aws-bucket/ && echo "  ✅ Test file uploaded to AWS"
else
    echo "  ❌ AWS CLI not configured"
fi

# Deploy to Azure
echo "Deploying to Azure..."
if command -v az &> /dev/null && az account show &>/dev/null; then
    # Create resource group
    az group create --name ${RESOURCE_PREFIX}-rg --location eastus &>/dev/null && echo "  ✅ Azure resource group created"
    
    # Create storage account
    az storage account create \
        --name ${RESOURCE_PREFIX}storage \
        --resource-group ${RESOURCE_PREFIX}-rg \
        --location eastus \
        --sku Standard_LRS &>/dev/null && echo "  ✅ Azure storage account created"
else
    echo "  ❌ Azure CLI not configured"
fi

# Deploy to GCP
echo "Deploying to GCP..."
if command -v gcloud &> /dev/null && gcloud auth list --filter=status:ACTIVE --format="value(account)" &>/dev/null; then
    # Create storage bucket
    gsutil mb gs://${RESOURCE_PREFIX}-gcp-bucket &>/dev/null && echo "  ✅ GCP storage bucket created"
    
    # Upload test file
    echo "GCP deployment - $(date)" > gcp-test.txt
    gsutil cp gcp-test.txt gs://${RESOURCE_PREFIX}-gcp-bucket/ && echo "  ✅ Test file uploaded to GCP"
else
    echo "  ❌ GCP CLI not configured"
fi

echo ""
echo "Deployment complete! Resources created with prefix: $RESOURCE_PREFIX"
EOF

chmod +x multi-cloud-deploy.sh
./multi-cloud-deploy.sh
```

**Exercise 3: Multi-Cloud Cleanup Script**
```bash
# Create cleanup script
cat > multi-cloud-cleanup.sh << 'EOF'
#!/bin/bash

echo "=== Multi-Cloud Resource Cleanup ==="
echo "This will delete resources created during Week 5 exercises"
read -p "Are you sure you want to continue? (y/N): " confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Cleanup cancelled"
    exit 0
fi

# AWS cleanup
echo "Cleaning up AWS resources..."
if command -v aws &> /dev/null; then
    # Delete S3 buckets (empty them first)
    for bucket in $(aws s3 ls | grep "multicloud-" | awk '{print $3}'); do
        aws s3 rm s3://$bucket --recursive &>/dev/null
        aws s3 rb s3://$bucket &>/dev/null && echo "  ✅ Deleted AWS bucket: $bucket"
    done
fi

# Azure cleanup
echo "Cleaning up Azure resources..."
if command -v az &> /dev/null; then
    # Delete resource groups
    for rg in $(az group list --query "[?contains(name, 'multicloud-') || contains(name, 'week5-')].name" -o tsv); do
        az group delete --name $rg --yes --no-wait &>/dev/null && echo "  ✅ Deleting Azure resource group: $rg"
    done
fi

# GCP cleanup
echo "Cleaning up GCP resources..."
if command -v gcloud &> /dev/null; then
    # Delete storage buckets
    for bucket in $(gsutil ls | grep "multicloud-" | sed 's|gs://||' | sed 's|/||'); do
        gsutil rm -r gs://$bucket &>/dev/null && echo "  ✅ Deleted GCP bucket: $bucket"
    done
    
    # Delete compute instances
    gcloud compute instances delete my-instance --zone us-central1-a --quiet &>/dev/null && echo "  ✅ Deleted GCP instance"
fi

echo "Cleanup initiated. Some resources may take time to fully delete."
EOF

chmod +x multi-cloud-cleanup.sh
# Run when ready: ./multi-cloud-cleanup.sh
```

---

## 🎯 Week 5 Summary & Assessment

### Skills Mastered
- ✅ **Azure Fundamentals** - Resource groups, VMs, storage accounts, networking
- ✅ **GCP Basics** - Projects, Compute Engine, Cloud Storage, VPC
- ✅ **Multi-Cloud CLI** - Azure CLI, gcloud, cross-platform automation
- ✅ **Service Mapping** - Understanding equivalent services across clouds
- ✅ **Cost Comparison** - Analyzing pricing across providers
- ✅ **Architecture Patterns** - Multi-cloud deployment strategies

### Key Commands Reference
```bash
# Azure CLI
az login, az group create, az vm create, az storage account create

# Google Cloud CLI
gcloud init, gcloud compute instances create, gsutil mb, gsutil cp

# Multi-Cloud
aws s3 ls, az storage account list, gsutil ls
```

### Practice Challenges

**Challenge 1: Multi-Cloud Web Application**
Deploy the same web application across all three clouds:
- AWS: EC2 + S3 + RDS
- Azure: VM + Blob Storage + SQL Database  
- GCP: Compute Engine + Cloud Storage + Cloud SQL

**Challenge 2: Cross-Cloud Data Sync**
Implement data synchronization between:
- AWS S3 buckets
- Azure Blob Storage
- GCP Cloud Storage

**Challenge 3: Multi-Cloud Monitoring**
Set up monitoring across all three platforms:
- AWS CloudWatch
- Azure Monitor
- GCP Cloud Monitoring

### Next Steps
You're ready for **Week 6: Cloud Architecture & Best Practices** where you'll learn:
- Well-architected framework principles
- Cost optimization strategies
- Disaster recovery planning
- Security best practices across clouds

---

## 📚 Additional Resources

### Documentation
- [Azure Architecture Center](https://docs.microsoft.com/en-us/azure/architecture/)
- [Google Cloud Architecture Framework](https://cloud.google.com/architecture/framework)
- [Multi-Cloud Strategy Guide](https://cloud.google.com/blog/topics/hybrid-cloud/new-solution-helps-you-move-to-a-multicloud-architecture)

### Certification Paths
- **Azure Fundamentals (AZ-900)** - Azure basics
- **Google Cloud Digital Leader** - GCP fundamentals
- **Multi-Cloud Architect** - Cross-platform expertise

**Ready for Week 6?** Continue to [Week 6: Cloud Architecture & Best Practices](../week-06-cloud-architecture/README.md)
