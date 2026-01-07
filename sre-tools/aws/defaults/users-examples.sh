
# AWS Development Environment

# This is an example of how to set up your AWS development environment variables. Make sure to replace `<YOUR_AWS_PROFILE>` and `<YOUR_AWS_REGION>` with your actual AWS profile name and region.
function dev() {
    echo -e "${CYAN}Setting AWS environment for Development Environment...${NC}"
    export AWS_PROFILE="dev"
    __login_east_1__
    __output_aws_connection_info__
}

function dev.login(){
    echo -e "${CYAN}Logging into AWS SSO for Development Environment...${NC}"
    export AWS_PROFILE="dev"
    __login_east_1__
    aws sso login --profile "${AWS_PROFILE}"
    __output_aws_connection_info__
}

function __login_east_1__(){
    export AWS_DEFAULT_REGION=us-east-1
    export AWS_REGION=us-east-1
}
