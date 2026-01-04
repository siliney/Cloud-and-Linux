# Week 4: AWS Fundamentals

## 🎯 Learning Objectives
By the end of this week, you will:
- Set up AWS account with proper security practices
- Master Identity and Access Management (IAM)
- Deploy and manage EC2 instances confidently
- Configure Virtual Private Cloud (VPC) networking
- Use S3 for object storage effectively
- Implement basic AWS security best practices

---

## Day 1-2: AWS Account Setup & IAM Mastery

### Understanding AWS Global Infrastructure

AWS operates in multiple **Regions** worldwide, each containing multiple **Availability Zones** (AZs):
- **Region** - Geographic area (us-east-1, eu-west-1)
- **Availability Zone** - Isolated data center within a region
- **Edge Locations** - CDN endpoints for CloudFront

### AWS Account Setup Best Practices

**Step 1: Create AWS Account**
1. Go to aws.amazon.com and click "Create an AWS Account"
2. Use a business email (not personal Gmail)
3. Choose "Personal" account type for learning
4. Complete phone verification

**Step 2: Secure Your Root Account**
```bash
# NEVER use root account for daily tasks!
# Root account should only be used for:
# - Billing and account settings
# - Creating first IAM admin user
# - Emergency access
```

**Step 3: Set Up Billing Alerts**
1. Go to Billing Dashboard
2. Set up billing alerts for $10, $50, $100
3. Enable detailed billing reports
4. Set up AWS Budgets

### Understanding IAM (Identity and Access Management)

IAM controls **who** can access **what** in your AWS account:

**Core IAM Components:**
- **Users** - Individual people or applications
- **Groups** - Collections of users with similar permissions
- **Roles** - Temporary permissions for services or cross-account access
- **Policies** - JSON documents defining permissions

### IAM Best Practices

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeImages"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Deny",
      "Action": [
        "ec2:TerminateInstances"
      ],
      "Resource": "*"
    }
  ]
}
```

### AWS CLI Setup and Configuration

```bash
# Install AWS CLI (if not already installed)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure AWS CLI
aws configure
# Enter: Access Key ID, Secret Access Key, Region (us-east-1), Output format (json)

# Test AWS CLI
aws sts get-caller-identity
aws iam list-users
aws ec2 describe-regions
```

### 🧪 Hands-On Exercise: Day 1-2

**Exercise 1: IAM User and Group Management**
```bash
# Create IAM group for developers
aws iam create-group --group-name Developers

# Create IAM user
aws iam create-user --user-name john-developer

# Add user to group
aws iam add-user-to-group --user-name john-developer --group-name Developers

# Create and attach policy to group
aws iam attach-group-policy --group-name Developers --policy-arn arn:aws:iam::aws:policy/PowerUserAccess

# Create access keys for user
aws iam create-access-key --user-name john-developer

# List users and groups
aws iam list-users
aws iam list-groups
```

**Exercise 2: IAM Role Creation**
```bash
# Create trust policy for EC2
cat > trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# Create IAM role
aws iam create-role --role-name EC2-S3-Access --assume-role-policy-document file://trust-policy.json

# Attach policy to role
aws iam attach-role-policy --role-name EC2-S3-Access --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess

# Create instance profile
aws iam create-instance-profile --instance-profile-name EC2-S3-Profile
aws iam add-role-to-instance-profile --instance-profile-name EC2-S3-Profile --role-name EC2-S3-Access
```

---

## Day 3-4: EC2 & VPC Fundamentals

### Understanding EC2 (Elastic Compute Cloud)

EC2 provides scalable virtual servers in the cloud. Key concepts:

**Instance Types:**
- **t3.micro** - Burstable performance, 1 vCPU, 1GB RAM (Free Tier)
- **t3.small** - Burstable performance, 2 vCPU, 2GB RAM
- **m5.large** - General purpose, 2 vCPU, 8GB RAM
- **c5.xlarge** - Compute optimized, 4 vCPU, 8GB RAM
- **r5.large** - Memory optimized, 2 vCPU, 16GB RAM

**Instance States:**
- **Pending** - Starting up
- **Running** - Active and billable
- **Stopping** - Shutting down
- **Stopped** - Shut down, not billable for compute
- **Terminated** - Permanently deleted

### VPC (Virtual Private Cloud) Fundamentals

VPC is your private network in AWS cloud:

**VPC Components:**
- **Subnets** - Network segments within AZs
- **Internet Gateway** - Provides internet access
- **Route Tables** - Control traffic routing
- **Security Groups** - Instance-level firewall (stateful)
- **NACLs** - Subnet-level firewall (stateless)
- **NAT Gateway** - Outbound internet for private subnets

**VPC Architecture Example:**
```
VPC (10.0.0.0/16)
├── Public Subnet (10.0.1.0/24) - AZ-1a
│   ├── Web Server (10.0.1.10)
│   └── Bastion Host (10.0.1.20)
├── Private Subnet (10.0.2.0/24) - AZ-1a
│   ├── App Server (10.0.2.10)
│   └── Database (10.0.2.20)
└── Private Subnet (10.0.3.0/24) - AZ-1b
    └── Database Replica (10.0.3.10)
```

### Security Groups vs NACLs

**Security Groups (Stateful):**
```bash
# Allow SSH from your IP
aws ec2 authorize-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 22 \
    --cidr 203.0.113.0/32

# Allow HTTP from anywhere
aws ec2 authorize-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0
```

### 🧪 Hands-On Exercise: Day 3-4

**Exercise 1: Create VPC and Subnets**
```bash
# Create VPC
VPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query 'Vpc.VpcId' --output text)
echo "VPC ID: $VPC_ID"

# Create Internet Gateway
IGW_ID=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)
aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID

# Create public subnet
PUBLIC_SUBNET_ID=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.1.0/24 \
    --availability-zone us-east-1a \
    --query 'Subnet.SubnetId' --output text)

# Create private subnet
PRIVATE_SUBNET_ID=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.2.0/24 \
    --availability-zone us-east-1a \
    --query 'Subnet.SubnetId' --output text)

# Create and configure route table for public subnet
ROUTE_TABLE_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text)
aws ec2 create-route --route-table-id $ROUTE_TABLE_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID
aws ec2 associate-route-table --subnet-id $PUBLIC_SUBNET_ID --route-table-id $ROUTE_TABLE_ID

# Enable auto-assign public IP for public subnet
aws ec2 modify-subnet-attribute --subnet-id $PUBLIC_SUBNET_ID --map-public-ip-on-launch
```

**Exercise 2: Launch EC2 Instance**
```bash
# Create key pair
aws ec2 create-key-pair --key-name my-key-pair --query 'KeyMaterial' --output text > my-key-pair.pem
chmod 400 my-key-pair.pem

# Create security group
SECURITY_GROUP_ID=$(aws ec2 create-security-group \
    --group-name web-server-sg \
    --description "Security group for web server" \
    --vpc-id $VPC_ID \
    --query 'GroupId' --output text)

# Add rules to security group
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 80 --cidr 0.0.0.0/0

# Launch EC2 instance
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id ami-0abcdef1234567890 \
    --instance-type t3.micro \
    --key-name my-key-pair \
    --security-group-ids $SECURITY_GROUP_ID \
    --subnet-id $PUBLIC_SUBNET_ID \
    --user-data file://user-data.sh \
    --query 'Instances[0].InstanceId' --output text)

echo "Instance ID: $INSTANCE_ID"

# Wait for instance to be running
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

# Get public IP
PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
echo "Public IP: $PUBLIC_IP"
```

**Exercise 3: Connect to Instance**
```bash
# Create user data script for web server
cat > user-data.sh << 'EOF'
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Hello from AWS EC2!</h1>" > /var/www/html/index.html
echo "<p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>" >> /var/www/html/index.html
EOF

# SSH to instance
ssh -i my-key-pair.pem ec2-user@$PUBLIC_IP

# Test web server
curl http://$PUBLIC_IP
```

---

## Day 5-7: S3 Storage & Security Best Practices

### Understanding S3 (Simple Storage Service)

S3 is object storage service with virtually unlimited capacity:

**Key Concepts:**
- **Buckets** - Containers for objects (globally unique names)
- **Objects** - Files stored in buckets (up to 5TB each)
- **Keys** - Object names/paths within buckets
- **Regions** - Geographic location of buckets

**S3 Storage Classes:**
- **Standard** - Frequently accessed data (99.999999999% durability)
- **Standard-IA** - Infrequently accessed data (lower cost)
- **One Zone-IA** - Infrequent access, single AZ (lowest cost)
- **Glacier** - Long-term archival (minutes to hours retrieval)
- **Glacier Deep Archive** - Lowest cost archival (12+ hours retrieval)

### S3 Security and Access Control

**Bucket Policies (Resource-based):**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-website-bucket/*"
    }
  ]
}
```

**Access Control Lists (ACLs):**
- Bucket ACLs - Control bucket access
- Object ACLs - Control individual object access

### S3 Features and Best Practices

**Versioning:**
```bash
# Enable versioning
aws s3api put-bucket-versioning --bucket my-bucket --versioning-configuration Status=Enabled

# List object versions
aws s3api list-object-versions --bucket my-bucket --prefix myfile.txt
```

**Encryption:**
```bash
# Server-side encryption with S3 managed keys (SSE-S3)
aws s3 cp file.txt s3://my-bucket/ --sse AES256

# Server-side encryption with KMS (SSE-KMS)
aws s3 cp file.txt s3://my-bucket/ --sse aws:kms --sse-kms-key-id alias/my-key
```

### 🧪 Hands-On Exercise: Day 5-7

**Exercise 1: S3 Bucket Operations**
```bash
# Create S3 bucket (name must be globally unique)
BUCKET_NAME="my-learning-bucket-$(date +%s)"
aws s3 mb s3://$BUCKET_NAME

# Upload files
echo "Hello S3!" > hello.txt
aws s3 cp hello.txt s3://$BUCKET_NAME/

# Upload with metadata
aws s3 cp hello.txt s3://$BUCKET_NAME/hello-with-metadata.txt --metadata purpose=learning,author=student

# List bucket contents
aws s3 ls s3://$BUCKET_NAME/

# Download file
aws s3 cp s3://$BUCKET_NAME/hello.txt downloaded-hello.txt

# Sync directory
mkdir test-dir
echo "File 1" > test-dir/file1.txt
echo "File 2" > test-dir/file2.txt
aws s3 sync test-dir/ s3://$BUCKET_NAME/test-dir/
```

**Exercise 2: S3 Website Hosting**
```bash
# Create website files
mkdir website
cat > website/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>My S3 Website</title>
</head>
<body>
    <h1>Welcome to My S3 Website!</h1>
    <p>This website is hosted on Amazon S3.</p>
</body>
</html>
EOF

cat > website/error.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Error</title>
</head>
<body>
    <h1>Page Not Found</h1>
    <p>The page you're looking for doesn't exist.</p>
</body>
</html>
EOF

# Upload website files
aws s3 sync website/ s3://$BUCKET_NAME/

# Configure static website hosting
aws s3 website s3://$BUCKET_NAME --index-document index.html --error-document error.html

# Make bucket public for website hosting
cat > bucket-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::$BUCKET_NAME/*"
    }
  ]
}
EOF

aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy file://bucket-policy.json

# Get website URL
echo "Website URL: http://$BUCKET_NAME.s3-website-us-east-1.amazonaws.com"
```

**Exercise 3: S3 Security and Lifecycle**
```bash
# Enable versioning
aws s3api put-bucket-versioning --bucket $BUCKET_NAME --versioning-configuration Status=Enabled

# Upload multiple versions
echo "Version 1" > version-test.txt
aws s3 cp version-test.txt s3://$BUCKET_NAME/
echo "Version 2" > version-test.txt
aws s3 cp version-test.txt s3://$BUCKET_NAME/

# List versions
aws s3api list-object-versions --bucket $BUCKET_NAME --prefix version-test.txt

# Create lifecycle policy
cat > lifecycle-policy.json << EOF
{
  "Rules": [
    {
      "ID": "TransitionToIA",
      "Status": "Enabled",
      "Filter": {
        "Prefix": "logs/"
      },
      "Transitions": [
        {
          "Days": 30,
          "StorageClass": "STANDARD_IA"
        },
        {
          "Days": 90,
          "StorageClass": "GLACIER"
        }
      ]
    }
  ]
}
EOF

aws s3api put-bucket-lifecycle-configuration --bucket $BUCKET_NAME --lifecycle-configuration file://lifecycle-policy.json
```

---

## 🎯 Week 4 Summary & Assessment

### Skills Mastered
- ✅ **AWS Account Security** - Root account protection, MFA, billing alerts
- ✅ **IAM Mastery** - Users, groups, roles, policies, best practices
- ✅ **EC2 Management** - Instance types, lifecycle, security groups
- ✅ **VPC Networking** - Subnets, routing, internet gateways, security
- ✅ **S3 Storage** - Buckets, objects, security, website hosting
- ✅ **AWS CLI Proficiency** - Command-line automation and scripting

### Key Commands Reference
```bash
# IAM
aws iam create-user, create-group, attach-policy, create-role

# EC2
aws ec2 run-instances, describe-instances, create-security-group

# VPC
aws ec2 create-vpc, create-subnet, create-internet-gateway

# S3
aws s3 mb, cp, sync, ls, website
aws s3api put-bucket-policy, put-bucket-versioning
```

### Practice Challenges

**Challenge 1: Multi-Tier Architecture**
Deploy a complete web application with:
- Public subnet with web servers
- Private subnet with application servers
- Database subnet with RDS
- Proper security groups and NACLs

**Challenge 2: S3 Data Pipeline**
Create an automated data processing pipeline:
- S3 bucket for data ingestion
- Lambda function triggered by S3 events
- Processed data stored in different S3 bucket
- CloudWatch monitoring and alerts

**Challenge 3: Cost Optimization**
Implement cost-saving measures:
- Right-size EC2 instances
- Use Reserved Instances
- Implement S3 lifecycle policies
- Set up detailed cost monitoring

### Next Steps
You're ready for **Week 5: Multi-Cloud & Azure/GCP Basics** where you'll learn:
- Azure fundamentals and resource management
- Google Cloud Platform basics
- Multi-cloud architecture patterns
- Cross-cloud service comparisons

---

## 📚 Additional Resources

### AWS Documentation
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [AWS Security Best Practices](https://aws.amazon.com/security/security-resources/)
- [EC2 User Guide](https://docs.aws.amazon.com/ec2/)

### Certification Preparation
- **AWS Cloud Practitioner** - Foundation level
- **AWS Solutions Architect Associate** - Most popular
- **AWS SysOps Administrator** - Operations focused

**Ready for Week 5?** Continue to [Week 5: Multi-Cloud & Azure/GCP Basics](../week-05-multi-cloud/README.md)
