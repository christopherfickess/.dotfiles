
## Login to monitoring AWS SSO and set environment variables
function aws.security.main() {
    echo -e "Setting AWS environment for ${CYAN}Security-Main...${NC}"
    export AWS_PROFILE="security-main"
    export AWS_DEFAULT_REGION=us-east-1
    export AWS_REGION=us-east-1
    __output_aws_connection_info__
}

function aws.security.main.login(){
    echo -e "Logging into AWS SSO for ${CYAN}Security-Main...${NC}"
    export AWS_PROFILE="security-main"
    export AWS_DEFAULT_REGION=us-east-1
    export AWS_REGION=us-east-1
    aws sso login --profile "${AWS_PROFILE}"
    __output_aws_connection_info__
}

function aws.security.main.connect(){
    echo -e "Logging into AWS SSO for ${CYAN}Security-Main...${NC}"
    aws.security.main
    aws.connect.eks_cluster "security-main"
}