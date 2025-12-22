#!/bin/bash

# ------------------
# Cost and Resource Management
# ------------------

function aws_resource_count() {
    local region="${AWS_REGION:-us-east-1}"
    
    echo -e "${CYAN}Counting AWS resources in region: ${region}...${NC}"
    echo -e "EC2 Instances: $(aws ec2 describe-instances --region "${region}" --query 'length(Reservations[*].Instances[*])' --output text)"
    echo -e "EBS Volumes: $(aws ec2 describe-volumes --region "${region}" --query 'length(Volumes[*])' --output text)"
    echo -e "S3 Buckets: $(aws s3 ls | wc -l)"
    echo -e "Lambda Functions: $(aws lambda list-functions --region "${region}" --query 'length(Functions[*])' --output text)"
    echo -e "EKS Clusters: $(aws eks list-clusters --region "${region}" --query 'length(clusters)' --output text)"
}