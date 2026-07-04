
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

# Login to sandbox AWS SSO and set environment variables
function aws.sandbox() {
    echo -e "Setting AWS environment for ${CYAN}Sandbox...${NC}"
    export AWS_PROFILE="dev"
    export AWS_DEFAULT_REGION=us-east-1
    export AWS_REGION=us-east-1
    __output_aws_connection_info__
}

function aws.sandbox.login(){
    echo -e "Logging into AWS SSO for ${CYAN}Sandbox...${NC}"
    export AWS_PROFILE="dev"
    export AWS_DEFAULT_REGION=us-east-1
    export AWS_REGION=us-east-1
    aws sso login --profile "${AWS_PROFILE}"
    __output_aws_connection_info__
}

function aws.sandbox.connect(){
    echo -e "Logging into AWS SSO for ${CYAN}Sandbox...${NC}"
    aws.sandbox
    aws.connect.eks_cluster "${__sandbox_eks_cluster_name__}"
}


function aws.test.login() {
    echo -e "Logging into AWS SSO for ${CYAN}Test...${NC}"
    export AWS_PROFILE="dev"
    export AWS_DEFAULT_REGION=us-east-1
    export AWS_REGION=us-east-1
    aws sso login --profile "${AWS_PROFILE}"
    __output_aws_connection_info__
}

function aws.test.connect() {
    echo -e "Logging into AWS SSO for ${CYAN}Test...${NC}"
    export AWS_DEFAULT_REGION=us-east-2
    export AWS_REGION=us-east-2
    aws.connect.eks_cluster "${__test_eks_cluster_name__}"
}

function aws.test.bastion.connect() {
    echo -e "Logging into AWS SSO for ${CYAN}Test Bastion...${NC}"
    export AWS_DEFAULT_REGION=us-east-2
    export AWS_REGION=us-east-2
    aws.connect.bastion "${__test_bastion_host_name__}"
}