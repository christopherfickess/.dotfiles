
# Login to prod AWS SSO and set environment variables
function aws.prod.mattermost() {
    echo -e "Setting AWS environment for ${CYAN}Mattermost Prod...${NC}"
    export AWS_PROFILE="prod"
    export AWS_DEFAULT_REGION=us-east-1
    export AWS_REGION=us-east-1

    __output_aws_connection_info__
}

function aws.prod.mattermost.login() {
    echo -e "Logging into AWS SSO for ${CYAN}Mattermost Prod...${NC}"
    export AWS_PROFILE="prod"
    export AWS_DEFAULT_REGION=us-east-1
    export AWS_REGION=us-east-1
    aws sso login --profile "${AWS_PROFILE}"
    __output_aws_connection_info__
}


function aws.prod.mattermost.connect() {
    echo -e "Logging into AWS SSO for ${CYAN}Mattermost Prod...${NC}"
    aws.prod.mattermost
    aws.connect.eks_cluster "${__prod_eks_cluster_name__}"
}
