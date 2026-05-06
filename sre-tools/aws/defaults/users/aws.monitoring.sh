
## Login to monitoring AWS SSO and set environment variables
function aws.monitoring.prod() {
    echo -e "Setting AWS environment for ${CYAN}Monitoring-Prod...${NC}"
    export AWS_PROFILE="monitoring-prod"
    export AWS_DEFAULT_REGION=us-east-1
    export AWS_REGION=us-east-1
    __output_aws_connection_info__
}

function aws.monitoring.prod.login(){
    echo -e "Logging into AWS SSO for ${CYAN}Monitoring-Prod...${NC}"
    export AWS_PROFILE="monitoring-prod"
    export AWS_DEFAULT_REGION=us-east-1
    export AWS_REGION=us-east-1
    aws sso login --profile "${AWS_PROFILE}"
    __output_aws_connection_info__
}

function aws.monitoring.prod.connect(){
    echo -e "Logging into AWS SSO for ${CYAN}Monitoring-Prod...${NC}"
    aws.monitoring.prod
    aws.connect.eks_cluster "${__monitoring_prod_eks_cluster_name__}"
}