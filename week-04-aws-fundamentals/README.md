# Week 4: AWS Fundamentals

## 🎯 Learning Objectives
- Set up AWS account and understand billing
- Master Identity and Access Management (IAM)
- Deploy and manage EC2 instances
- Configure Virtual Private Cloud (VPC)
- Use S3 for object storage
- Implement basic security best practices

---

## Day 1-2: AWS Account Setup & IAM

### AWS Account Setup
1. **Create AWS Account** at aws.amazon.com
2. **Set up billing alerts** immediately
3. **Enable MFA** on root account
4. **Create IAM admin user** (never use root for daily tasks)

### Understanding IAM
IAM controls **who** can access **what** in your AWS account:
- **Users** - Individual people or applications
- **Groups** - Collections of users with similar permissions
- **Roles** - Temporary permissions for services or users
- **Policies** - JSON documents defining permissions

### IAM Best Practices
```bash
# AWS CLI setup
aws configure
# Enter: Access Key ID, Secret Access Key, Region (us-east-1), Output format (json)

# Test AWS CLI
aws sts get-caller-identity
aws iam list-users
```

### 🧪 Hands-On Exercise: Day 1-2
```bash
# Create IAM user via CLI
aws iam create-user --user-name developer
aws iam create-access-key --user-name developer

# Create and attach policy
aws iam attach-user-policy --user-name developer --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
```

---

## Day 3-4: EC2 & VPC Fundamentals

### EC2 Instance Types
- **t3.micro** - Burstable performance (Free Tier)
- **m5.large** - General purpose
- **c5.xlarge** - Compute optimized
- **r5.large** - Memory optimized

### VPC Components
- **Subnets** - Network segments (public/private)
- **Internet Gateway** - Internet access
- **Route Tables** - Traffic routing rules
- **Security Groups** - Instance-level firewall
- **NACLs** - Subnet-level firewall

### 🧪 Hands-On Exercise: Day 3-4
```bash
# Launch EC2 instance
aws ec2 run-instances \
    --image-id ami-0abcdef1234567890 \
    --instance-type t3.micro \
    --key-name my-key-pair \
    --security-group-ids sg-12345678 \
    --subnet-id subnet-12345678

# List instances
aws ec2 describe-instances --query 'Reservations[].Instances[].{ID:InstanceId,State:State.Name,IP:PublicIpAddress}'
```

---

## Day 5-7: S3 & Security

### S3 Storage Classes
- **Standard** - Frequently accessed data
- **IA (Infrequent Access)** - Less frequent access
- **Glacier** - Long-term archival
- **Deep Archive** - Lowest cost archival

### Security Best Practices
- Use IAM roles instead of access keys
- Enable CloudTrail for auditing
- Encrypt data at rest and in transit
- Regular security reviews

### 🧪 Hands-On Exercise: Day 5-7
```bash
# Create S3 bucket
aws s3 mb s3://my-unique-bucket-name-12345

# Upload file
echo "Hello AWS" > test.txt
aws s3 cp test.txt s3://my-unique-bucket-name-12345/

# List bucket contents
aws s3 ls s3://my-unique-bucket-name-12345/
```
