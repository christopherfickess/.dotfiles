#!/bin/bash
# ------------------
# EC2 Deployment and Testing Functions
# ------------------

function ec2_list_instances() {
    local filters="${1}"
    local region="${AWS_REGION:-us-east-1}"
    
    echo -e "${CYAN}Listing EC2 instances in region: ${region}...${NC}"
    
    if [ -z "${filters}" ]; then
        aws ec2 describe-instances \
            --region "${region}" \
            --query "Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,PrivateIpAddress,PublicIpAddress,Tags[?Key=='Name']|[0].Value]" \
            --output table
    else
        aws ec2 describe-instances \
            --region "${region}" \
            --filters "${filters}" \
            --query "Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,PrivateIpAddress,PublicIpAddress,Tags[?Key=='Name']|[0].Value]" \
            --output table
    fi
}

function ec2_start_instance() {
    local instance_id="${1}"
    
    if [ -z "${instance_id}" ]; then
        echo -e "${RED}Usage: ec2_start_instance <instance-id>${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Starting instance: ${instance_id}...${NC}"
    aws ec2 start-instances --instance-ids "${instance_id}"
    aws ec2 wait instance-running --instance-ids "${instance_id}"
    echo -e "${GREEN}Instance started.${NC}"
}

function ec2_stop_instance() {
    local instance_id="${1}"
    
    if [ -z "${instance_id}" ]; then
        echo -e "${RED}Usage: ec2_stop_instance <instance-id>${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Stopping instance: ${instance_id}...${NC}"
    aws ec2 stop-instances --instance-ids "${instance_id}"
    aws ec2 wait instance-stopped --instance-ids "${instance_id}"
    echo -e "${GREEN}Instance stopped.${NC}"
}

function ec2_get_console_output() {
    local instance_id="${1}"
    
    if [ -z "${instance_id}" ]; then
        echo -e "${RED}Usage: ec2_get_console_output <instance-id>${NC}"
        return 1
    fi
    
    echo -e "${CYAN}Getting console output for instance: ${instance_id}...${NC}"
    aws ec2 get-console-output --instance-id "${instance_id}" --output text
}