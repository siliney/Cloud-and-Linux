# Week 6: Cloud Architecture & Best Practices

## 🎯 Learning Objectives
By the end of this week, you will:
- Apply well-architected framework principles
- Design cost-effective cloud solutions
- Implement disaster recovery strategies
- Apply security best practices across cloud platforms
- Optimize performance and reliability

---

## Day 1-2: Well-Architected Framework Principles

### The Five Pillars of Well-Architected Design

**1. Operational Excellence**
- Automate operations and deployments
- Monitor systems and respond to events
- Continuously improve processes
- Document and share knowledge

**2. Security**
- Implement defense in depth
- Apply security at all layers
- Enable traceability and audit trails
- Automate security best practices

**3. Reliability**
- Design for failure scenarios
- Implement redundancy and failover
- Monitor and alert on issues
- Test disaster recovery procedures

**4. Performance Efficiency**
- Right-size resources for workloads
- Use appropriate technologies
- Monitor performance metrics
- Optimize based on data

**5. Cost Optimization**
- Understand spending patterns
- Right-size and scale resources
- Use reserved capacity when appropriate
- Continuously optimize costs

### 🧪 Hands-On Exercise: Day 1-2

**Exercise 1: Architecture Assessment Tool**
```bash
# Create architecture assessment script
cat > architecture-assessment.sh << 'EOF'
#!/bin/bash

echo "=== Cloud Architecture Assessment ==="
echo "Date: $(date)"
echo ""

# Function to check AWS resources
check_aws_architecture() {
    echo "=== AWS Architecture Review ==="
    
    if ! command -v aws &> /dev/null; then
        echo "❌ AWS CLI not installed"
        return
    fi
    
    if ! aws sts get-caller-identity &>/dev/null; then
        echo "❌ AWS not authenticated"
        return
    fi
    
    echo "✅ AWS CLI configured"
    
    # Check for multi-AZ deployments
    echo "Checking Multi-AZ deployments..."
    instance_azs=$(aws ec2 describe-instances --query 'Reservations[].Instances[?State.Name==`running`].Placement.AvailabilityZone' --output text | sort | uniq | wc -l)
    if [ $instance_azs -gt 1 ]; then
        echo "✅ Multi-AZ deployment detected ($instance_azs AZs)"
    else
        echo "⚠️  Single AZ deployment - consider multi-AZ for reliability"
    fi
    
    # Check for encrypted storage
    echo "Checking encryption..."
    encrypted_volumes=$(aws ec2 describe-volumes --query 'Volumes[?Encrypted==`true`]' --output text | wc -l)
    total_volumes=$(aws ec2 describe-volumes --query 'Volumes' --output text | wc -l)
    if [ $encrypted_volumes -eq $total_volumes ] && [ $total_volumes -gt 0 ]; then
        echo "✅ All volumes encrypted"
    else
        echo "⚠️  Some volumes not encrypted - enable encryption for security"
    fi
    
    # Check for backup/snapshot strategy
    echo "Checking backup strategy..."
    snapshots=$(aws ec2 describe-snapshots --owner-ids self --query 'Snapshots' --output text | wc -l)
    if [ $snapshots -gt 0 ]; then
        echo "✅ Snapshots found - backup strategy in place"
    else
        echo "⚠️  No snapshots found - implement backup strategy"
    fi
}

# Function to provide recommendations
provide_recommendations() {
    echo ""
    echo "=== Architecture Recommendations ==="
    echo "1. Operational Excellence:"
    echo "   - Implement Infrastructure as Code (Terraform/CloudFormation)"
    echo "   - Set up automated deployments"
    echo "   - Configure comprehensive monitoring"
    echo ""
    echo "2. Security:"
    echo "   - Enable encryption at rest and in transit"
    echo "   - Implement least privilege access"
    echo "   - Regular security audits"
    echo ""
    echo "3. Reliability:"
    echo "   - Deploy across multiple AZs/regions"
    echo "   - Implement auto-scaling"
    echo "   - Regular disaster recovery testing"
    echo ""
    echo "4. Performance:"
    echo "   - Right-size instances based on metrics"
    echo "   - Use CDN for static content"
    echo "   - Implement caching strategies"
    echo ""
    echo "5. Cost Optimization:"
    echo "   - Use reserved instances for predictable workloads"
    echo "   - Implement auto-scaling to match demand"
    echo "   - Regular cost reviews and optimization"
}

# Run assessment
check_aws_architecture
provide_recommendations
EOF

chmod +x architecture-assessment.sh
./architecture-assessment.sh
```

---

## Day 3-4: Cost Optimization Strategies

### Understanding Cloud Costs

**Cost Components:**
- **Compute**: Virtual machines, containers, serverless
- **Storage**: Block, object, file storage
- **Network**: Data transfer, load balancers
- **Services**: Databases, analytics, AI/ML

### Cost Optimization Techniques

**1. Right-Sizing Resources**
```bash
# AWS Cost optimization script
cat > cost-optimization.sh << 'EOF'
#!/bin/bash

echo "=== Cloud Cost Optimization Analysis ==="

# Check for underutilized EC2 instances
echo "Analyzing EC2 instance utilization..."
aws cloudwatch get-metric-statistics \
    --namespace AWS/EC2 \
    --metric-name CPUUtilization \
    --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
    --statistics Average \
    --start-time $(date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%S) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
    --period 86400 \
    --query 'Datapoints[?Average<`10`]' \
    --output table

# Check for unused EBS volumes
echo "Finding unattached EBS volumes..."
aws ec2 describe-volumes \
    --filters Name=status,Values=available \
    --query 'Volumes[].{VolumeId:VolumeId,Size:Size,VolumeType:VolumeType}' \
    --output table

# Check for unused Elastic IPs
echo "Finding unused Elastic IPs..."
aws ec2 describe-addresses \
    --query 'Addresses[?!InstanceId].{PublicIp:PublicIp,AllocationId:AllocationId}' \
    --output table
EOF

chmod +x cost-optimization.sh
```

**2. Reserved Instances and Savings Plans**
```bash
# Reserved Instance recommendation script
cat > ri-recommendations.sh << 'EOF'
#!/bin/bash

echo "=== Reserved Instance Recommendations ==="

# Get running instances for RI analysis
aws ec2 describe-instances \
    --filters Name=instance-state-name,Values=running \
    --query 'Reservations[].Instances[].[InstanceType,Placement.AvailabilityZone]' \
    --output table

echo ""
echo "Recommendations:"
echo "1. Analyze instance usage patterns over 30+ days"
echo "2. Consider 1-year term for development workloads"
echo "3. Consider 3-year term for production workloads"
echo "4. Use Convertible RIs for flexibility"
echo "5. Consider Savings Plans for compute flexibility"
EOF

chmod +x ri-recommendations.sh
```

### 🧪 Hands-On Exercise: Day 3-4

**Exercise 1: Cost Monitoring Setup**
```bash
# Create cost monitoring and alerting
cat > setup-cost-monitoring.sh << 'EOF'
#!/bin/bash

echo "=== Setting up Cost Monitoring ==="

# Create SNS topic for cost alerts
TOPIC_ARN=$(aws sns create-topic --name cost-alerts --query 'TopicArn' --output text)
echo "Created SNS topic: $TOPIC_ARN"

# Subscribe email to topic (replace with your email)
aws sns subscribe \
    --topic-arn $TOPIC_ARN \
    --protocol email \
    --notification-endpoint your-email@example.com

# Create cost budget
cat > budget.json << EOL
{
  "BudgetName": "Monthly-Budget",
  "BudgetLimit": {
    "Amount": "100",
    "Unit": "USD"
  },
  "TimeUnit": "MONTHLY",
  "BudgetType": "COST",
  "CostFilters": {},
  "TimePeriod": {
    "Start": "$(date +%Y-%m-01)",
    "End": "2030-12-31"
  }
}
EOL

# Create notification for budget
cat > notification.json << EOL
{
  "Notification": {
    "NotificationType": "ACTUAL",
    "ComparisonOperator": "GREATER_THAN",
    "Threshold": 80,
    "ThresholdType": "PERCENTAGE"
  },
  "Subscribers": [
    {
      "SubscriptionType": "EMAIL",
      "Address": "your-email@example.com"
    }
  ]
}
EOL

# Create the budget with notification
aws budgets create-budget \
    --account-id $(aws sts get-caller-identity --query Account --output text) \
    --budget file://budget.json \
    --notifications-with-subscribers file://notification.json

echo "Cost monitoring setup complete!"
EOF

chmod +x setup-cost-monitoring.sh
```

---

## Day 5-7: Disaster Recovery & Business Continuity

### DR Strategy Framework

**Recovery Objectives:**
- **RTO (Recovery Time Objective)**: Maximum acceptable downtime
- **RPO (Recovery Point Objective)**: Maximum acceptable data loss

**DR Patterns:**
1. **Backup and Restore** (RTO: hours, RPO: hours)
2. **Pilot Light** (RTO: 10s of minutes, RPO: minutes)
3. **Warm Standby** (RTO: minutes, RPO: seconds)
4. **Multi-Site Active/Active** (RTO: seconds, RPO: near-zero)

### 🧪 Hands-On Exercise: Day 5-7

**Exercise 1: Automated Backup Strategy**
```bash
# Create comprehensive backup script
cat > backup-strategy.sh << 'EOF'
#!/bin/bash

echo "=== Implementing Backup Strategy ==="

# Function to create EBS snapshots
create_ebs_snapshots() {
    echo "Creating EBS snapshots..."
    
    # Get all volumes
    volumes=$(aws ec2 describe-volumes --query 'Volumes[].VolumeId' --output text)
    
    for volume in $volumes; do
        # Create snapshot
        snapshot_id=$(aws ec2 create-snapshot \
            --volume-id $volume \
            --description "Automated backup $(date +%Y-%m-%d)" \
            --query 'SnapshotId' --output text)
        
        # Tag snapshot
        aws ec2 create-tags \
            --resources $snapshot_id \
            --tags Key=Name,Value="Auto-Backup-$volume" \
                   Key=CreatedBy,Value="BackupScript" \
                   Key=RetentionDays,Value="30"
        
        echo "Created snapshot $snapshot_id for volume $volume"
    done
}

# Function to backup S3 to another region
backup_s3_cross_region() {
    echo "Setting up S3 cross-region replication..."
    
    # Create replication bucket in different region
    BACKUP_BUCKET="backup-$(date +%s)-us-west-2"
    aws s3 mb s3://$BACKUP_BUCKET --region us-west-2
    
    # Enable versioning on both buckets
    aws s3api put-bucket-versioning \
        --bucket $BACKUP_BUCKET \
        --versioning-configuration Status=Enabled
    
    echo "Backup bucket created: $BACKUP_BUCKET"
}

# Function to create RDS snapshots
create_rds_snapshots() {
    echo "Creating RDS snapshots..."
    
    # Get all RDS instances
    instances=$(aws rds describe-db-instances --query 'DBInstances[].DBInstanceIdentifier' --output text)
    
    for instance in $instances; do
        snapshot_id="$instance-backup-$(date +%Y%m%d%H%M%S)"
        aws rds create-db-snapshot \
            --db-instance-identifier $instance \
            --db-snapshot-identifier $snapshot_id
        
        echo "Created RDS snapshot $snapshot_id for instance $instance"
    done
}

# Function to cleanup old backups
cleanup_old_backups() {
    echo "Cleaning up old backups..."
    
    # Delete snapshots older than 30 days
    old_snapshots=$(aws ec2 describe-snapshots \
        --owner-ids self \
        --query "Snapshots[?StartTime<='$(date -d '30 days ago' -u +%Y-%m-%dT%H:%M:%S.000Z)'].SnapshotId" \
        --output text)
    
    for snapshot in $old_snapshots; do
        aws ec2 delete-snapshot --snapshot-id $snapshot
        echo "Deleted old snapshot: $snapshot"
    done
}

# Run backup functions
create_ebs_snapshots
backup_s3_cross_region
create_rds_snapshots
cleanup_old_backups

echo "Backup strategy implementation complete!"
EOF

chmod +x backup-strategy.sh
```

**Exercise 2: Disaster Recovery Testing**
```bash
# Create DR testing script
cat > dr-testing.sh << 'EOF'
#!/bin/bash

echo "=== Disaster Recovery Testing ==="

# Function to test backup restoration
test_backup_restoration() {
    echo "Testing backup restoration..."
    
    # Find latest snapshot
    latest_snapshot=$(aws ec2 describe-snapshots \
        --owner-ids self \
        --query 'Snapshots | sort_by(@, &StartTime) | [-1].SnapshotId' \
        --output text)
    
    if [ "$latest_snapshot" != "None" ]; then
        echo "Latest snapshot found: $latest_snapshot"
        
        # Create volume from snapshot (for testing)
        test_volume=$(aws ec2 create-volume \
            --snapshot-id $latest_snapshot \
            --availability-zone us-east-1a \
            --tag-specifications 'ResourceType=volume,Tags=[{Key=Name,Value=DR-Test-Volume}]' \
            --query 'VolumeId' --output text)
        
        echo "Test volume created: $test_volume"
        echo "✅ Backup restoration test successful"
        
        # Cleanup test volume
        aws ec2 delete-volume --volume-id $test_volume
        echo "Test volume cleaned up"
    else
        echo "❌ No snapshots found for testing"
    fi
}

# Function to test cross-region connectivity
test_cross_region_connectivity() {
    echo "Testing cross-region connectivity..."
    
    # Test connectivity to different regions
    regions=("us-east-1" "us-west-2" "eu-west-1")
    
    for region in "${regions[@]}"; do
        echo "Testing connectivity to $region..."
        if aws ec2 describe-regions --region $region &>/dev/null; then
            echo "✅ $region connectivity successful"
        else
            echo "❌ $region connectivity failed"
        fi
    done
}

# Function to validate RTO/RPO metrics
validate_rto_rpo() {
    echo "Validating RTO/RPO metrics..."
    
    echo "RTO Targets:"
    echo "  - Critical systems: < 1 hour"
    echo "  - Important systems: < 4 hours"
    echo "  - Standard systems: < 24 hours"
    echo ""
    echo "RPO Targets:"
    echo "  - Critical data: < 15 minutes"
    echo "  - Important data: < 1 hour"
    echo "  - Standard data: < 24 hours"
    echo ""
    echo "⚠️  Conduct regular DR drills to validate these metrics"
}

# Run DR tests
test_backup_restoration
test_cross_region_connectivity
validate_rto_rpo

echo "DR testing complete!"
EOF

chmod +x dr-testing.sh
```

---

## 🎯 Week 6 Summary & Assessment

### Skills Mastered
- ✅ **Well-Architected Design** - Applied five pillars to cloud architecture
- ✅ **Cost Optimization** - Implemented cost monitoring and optimization strategies
- ✅ **Disaster Recovery** - Designed and tested backup and recovery procedures
- ✅ **Security Best Practices** - Applied security principles across cloud platforms
- ✅ **Performance Optimization** - Implemented monitoring and optimization techniques

### Key Concepts Reference
```bash
# Architecture Assessment
- Multi-AZ deployments
- Encryption at rest/transit
- Backup strategies
- Cost monitoring

# Cost Optimization
- Right-sizing instances
- Reserved instances
- Unused resource cleanup
- Budget alerts

# Disaster Recovery
- RTO/RPO planning
- Cross-region backups
- DR testing procedures
- Business continuity
```

### Practice Challenges

**Challenge 1: Complete Architecture Review**
Conduct a comprehensive review of existing infrastructure:
- Security assessment
- Cost optimization opportunities
- Reliability improvements
- Performance bottlenecks

**Challenge 2: Multi-Region DR Setup**
Implement complete disaster recovery:
- Primary region: us-east-1
- DR region: us-west-2
- Automated failover procedures
- Regular DR testing

**Challenge 3: Cost Optimization Project**
Achieve 30% cost reduction through:
- Instance right-sizing
- Reserved instance purchases
- Unused resource cleanup
- Automated scaling policies

### Next Steps
You're ready for **Week 7: Docker Mastery** where you'll learn:
- Container fundamentals and benefits
- Docker image creation and optimization
- Container networking and storage
- Docker Compose for multi-container applications

---

## 📚 Additional Resources

### Documentation
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Azure Architecture Center](https://docs.microsoft.com/en-us/azure/architecture/)
- [Google Cloud Architecture Framework](https://cloud.google.com/architecture/framework)

### Tools
- [AWS Trusted Advisor](https://aws.amazon.com/support/trusted-advisor/)
- [Azure Advisor](https://azure.microsoft.com/en-us/services/advisor/)
- [Google Cloud Recommender](https://cloud.google.com/recommender)

**Ready for Week 7?** Continue to [Week 7: Docker Mastery](../week-07-docker-mastery/README.md)
