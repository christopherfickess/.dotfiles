
## Login to dev AWS SSO and set environment variables
function aws.dev() {
    echo -e "Setting AWS environment for ${CYAN}Development...${NC}"
    export AWS_PROFILE="dev"
    export AWS_DEFAULT_REGION=us-east-1
    export AWS_REGION=us-east-1
    __output_aws_connection_info__
}

function aws.dev.login(){
    echo -e "Logging into AWS SSO for ${CYAN}Development...${NC}"
    export AWS_PROFILE="dev"
    export AWS_DEFAULT_REGION=us-east-1
    export AWS_REGION=us-east-1
    aws sso login --profile "${AWS_PROFILE}"
    __output_aws_connection_info__
}

function aws.dev.connect(){
    echo -e "Logging into AWS SSO for ${CYAN}Development...${NC}"
    aws.dev
    aws.connect.eks_cluster "${__dev_eks_cluster_name__}"
}
