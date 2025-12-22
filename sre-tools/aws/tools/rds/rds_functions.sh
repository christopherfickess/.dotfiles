# !/bin/bash

# ------------------
# RDS Functions
# ------------------

function rds_list_instances() {
    local region="${AWS_REGION:-us-east-1}"
    
    echo -e "${CYAN}Listing RDS instances in region: ${region}...${NC}"
    aws rds describe-db-instances \
        --region "${region}" \
        --query "DBInstances[*].[DBInstanceIdentifier,Engine,DBInstanceStatus,Endpoint.Address]" \
        --output table
}