#!/bin/bash
# ------------------
# Security and Networking Functions
# ------------------

function sg_list_security_groups() {
    local vpc_id="${1}"
    local region="${AWS_REGION:-us-east-1}"
    
    echo -e "${CYAN}Listing security groups${NC}"
    if [ -n "${vpc_id}" ]; then
        echo -e "   Filtering by VPC: ${vpc_id}${NC}"
        aws ec2 describe-security-groups \
            --filters "Name=vpc-id,Values=${vpc_id}" \
            --region "${region}" \
            --query "SecurityGroups[*].[GroupId,GroupName,Description]" \
            --output table
    else
        aws ec2 describe-security-groups \
            --region "${region}" \
            --query "SecurityGroups[*].[GroupId,GroupName,Description,VpcId]" \
            --output table
    fi
}

function vpc_list_vpcs() {
    local region="${AWS_REGION:-us-east-1}"
    
    echo -e "${CYAN}Listing VPCs in region: ${region}...${NC}"
    aws ec2 describe-vpcs \
        --region "${region}" \
        --query "Vpcs[*].[VpcId,CidrBlock,State,Tags[?Key=='Name']|[0].Value]" \
        --output table
}
