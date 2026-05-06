
## Login to release-prod AWS SSO and set environment variables
function aws.release.prod() {
    echo -e "Setting AWS environment for ${CYAN}Release-Prod...${NC}"
    export AWS_PROFILE="release-prod"
    export AWS_DEFAULT_REGION=us-east-1
    export AWS_REGION=us-east-1
    __output_aws_connection_info__
}

function aws.release.prod.login(){
    echo -e "Logging into AWS SSO for ${CYAN}Release-Prod...${NC}"
    export AWS_PROFILE="release-prod"
    export AWS_DEFAULT_REGION=us-east-1
    export AWS_REGION=us-east-1
    aws sso login --profile "${AWS_PROFILE}"
    __output_aws_connection_info__
}

function aws.release.prod.connect(){
    echo -e "Logging into AWS SSO for ${CYAN}Release-Prod...${NC}"
    aws.release.prod
    aws.connect.eks_cluster "${__release_prod_eks_cluster_name__}"
}


## Login to release-main AWS SSO and set environment variables
function aws.release.main() {
    echo -e "Setting AWS environment for ${CYAN}Release-Main...${NC}"
    export AWS_PROFILE="release-prod"
    export AWS_DEFAULT_REGION=us-east-1
    export AWS_REGION=us-east-1
    __output_aws_connection_info__
}

function aws.release.main.login(){
    echo -e "Logging into AWS SSO for ${CYAN}Release-Main...${NC}"
    export AWS_PROFILE="release-prod"
    export AWS_DEFAULT_REGION=us-east-1
    export AWS_REGION=us-east-1
    aws sso login --profile "${AWS_PROFILE}"
    __output_aws_connection_info__
}

function aws.release.main.connect(){
    echo -e "Logging into AWS SSO for ${CYAN}Release-Main...${NC}"
    aws.release.main
    aws.connect.eks_cluster "${__release_main_eks_cluster_name__}"
}