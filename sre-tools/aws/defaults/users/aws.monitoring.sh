
## Login to monitoring AWS SSO and set environment variables
function aws.monitoring.main() {
    echo -e "Setting AWS environment for ${CYAN}Monitoring-Main...${NC}"
    export AWS_PROFILE="monitoring-main"
    export AWS_DEFAULT_REGION=us-east-1
    export AWS_REGION=us-east-1
    __output_aws_connection_info__
}

function aws.monitoring.main.login(){
    echo -e "Logging into AWS SSO for ${CYAN}Monitoring-Main...${NC}"
    export AWS_PROFILE="monitoring-main"
    export AWS_DEFAULT_REGION=us-east-1
    export AWS_REGION=us-east-1
    aws sso login --profile "${AWS_PROFILE}"
    __output_aws_connection_info__
}

function aws.monitoring.main.connect(){
    echo -e "Logging into AWS SSO for ${CYAN}Monitoring-Main...${NC}"
    aws.monitoring.main
    aws.connect.eks_cluster "${__monitoring_main_eks_cluster_name__}"
}