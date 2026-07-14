
## Login to networking-main AWS SSO and set environment variables
function aws.networking.main() {
    echo -e "Setting AWS environment for ${CYAN}Networking-Main...${NC}"
    export AWS_PROFILE="networking-main"
    export AWS_DEFAULT_REGION=us-east-1
    export AWS_REGION=us-east-1
    __output_aws_connection_info__
}

function aws.networking.main.login(){
    echo -e "Logging into AWS SSO for ${CYAN}Networking-Main...${NC}"
    export AWS_PROFILE="networking-main"
    export AWS_DEFAULT_REGION=us-east-1
    export AWS_REGION=us-east-1
    aws sso login --profile "${AWS_PROFILE}"
    __output_aws_connection_info__
}

function aws.networking.main.connect(){
    echo -e "Logging into AWS SSO for ${CYAN}Networking-Main...${NC}"
    aws.networking.main
    aws.connect.eks_cluster "networking-main"
}