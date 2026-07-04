
function myhelp_aws() {
    echo -e "${__HEADER_COLOR__}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${__HEADER_COLOR__} AWS Functions${NC}"
    echo -e "${__HEADER_COLOR__}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [[ ! -z "${__AWS_FILE}" ]]; then
        __myhelp_aws_sre_tools__
    else
        __myhelp_aws__
    fi

    echo ""
    if [[ "${SRE_TOOLS_VERBOSE:-false}" != "true" ]]; then
        echo -e "${__COMMAND_COLOR__}Tip:${NC} Set ${__DETAILS_COLOR__}SRE_TOOLS_VERBOSE=true${NC} or use ${__DETAILS_COLOR__}myhelp -v${NC} for all AWS commands"
    fi
    echo ""
    echo -e "For more information: ${__INFO_COLOR__}https://docs.aws.amazon.com/cli/latest/reference/${NC}"
}

function __myhelp_aws__() {
    if [[ "${SRE_TOOLS_VERBOSE:-false}" == "true" ]]; then
        __myhelp_aws_toplevel_advanced__
    else
        __myhelp_aws_toplevel_basic__
    fi
}

function __myhelp_aws_toplevel_basic__() {
    echo -e "${BOLD}Common Commands:${NC}"
    echo -e "  ${__COMMAND_COLOR__}aws.display.auth${NC}            Display AWS credentials file and config"
    echo -e "  ${__COMMAND_COLOR__}aws.profile.switch${NC}           Switch AWS profiles"
    echo -e "  ${__COMMAND_COLOR__}aws.connect.ssm.parse.command${NC}           Run command on EC2 instance via SSM"
    echo -e "  ${__COMMAND_COLOR__}aws.sts.assume.role${NC}           Assume an AWS IAM role"
    __myhelp_aws_client_connect__
}

function __myhelp_aws_toplevel_advanced__() {
    __myhelp_aws_toplevel_basic__
    echo ""
    echo -e "${BOLD}Getter Commands:${NC}"
    echo -e "  ${__COMMAND_COLOR__}aws.get.eks_cluster.id <cluster-name>${NC}       Get EKS cluster ARN by name"
    echo -e "  ${__COMMAND_COLOR__}aws.get.eks_cluster.info <cluster name>${NC}     Get detailed info about an EKS cluster"
    echo -e "  ${__COMMAND_COLOR__}aws.get.rds_cluster.id <cluster-name>${NC}       Get RDS cluster ID by name"
    echo -e "  ${__COMMAND_COLOR__}aws.get.rds_cluster.info <cluster-name>${NC}     Get detailed info about an RDS cluster"
    echo -e "  ${__COMMAND_COLOR__}aws.get.s3_bucket.id <bucket-name>${NC}          Get S3 bucket name by name"
    echo -e "  ${__COMMAND_COLOR__}aws.get.s3_bucket.info <bucket-name>${NC}        Get detailed info about an S3 bucket"
    echo
    echo -e "${BOLD}Connect Commands:${NC}"
    echo -e "  ${__COMMAND_COLOR__}aws.connect.ec2.ssm <instance-id>${NC}           Connect to EC2 instance via SSM"
    echo -e "  ${__COMMAND_COLOR__}aws.connect.eks_cluster <cluster-name>${NC}      Connect to EKS cluster and update kubeconfig"  
    echo 
    echo -e "${BOLD}List Commands:${NC}"
    echo -e "  ${__COMMAND_COLOR__}aws.list.ec2_instances${NC}           List EC2 instances in the current region"
    echo -e "  ${__COMMAND_COLOR__}aws.list.eks_clusters${NC}           List EKS clusters in the current region"
    echo -e "  ${__COMMAND_COLOR__}aws.list.rds_clusters${NC}           List RDS clusters in the current region"
    __myhelp_aws_client_connect__
}

function __myhelp_aws_client_connect__() {
    echo ""
    echo -e "${BOLD}Developer Connect Commands:${NC}"
    echo -e "  ${__COMMAND_COLOR__}aws.dev${NC}             Setup ENV to development AWS environment"
    echo -e "  ${__COMMAND_COLOR__}aws.dev.login${NC}       Login to development AWS environment"
    echo -e "  ${__COMMAND_COLOR__}aws.dev.connect${NC}     Connect to development AWS environment"
    echo    ""
    echo -e "${BOLD}Production Connect Commands:${NC}"
    echo -e "  ${__COMMAND_COLOR__}aws.prod.mattermost${NC}             Setup ENV to production AWS environment"
    echo -e "  ${__COMMAND_COLOR__}aws.prod.mattermost.login${NC}       Login to production AWS environment"
    echo -e "  ${__COMMAND_COLOR__}aws.prod.mattermost.connect${NC}     Connect to production AWS environment"
    echo ""
    echo -e "${BOLD}Customer Connect Commands:${NC}"
    echo -e "  ${__COMMAND_COLOR__}aws.byoc.iron-badger.prod${NC}               Setup ENV to Iron Badger Prod AWS Account"
    echo -e "  ${__COMMAND_COLOR__}aws.byoc.iron-badger.prod.login${NC}         Login to Iron Badger Prod AWS Account using sso"
    echo -e "  ${__COMMAND_COLOR__}aws.byoc.iron-badger.staging${NC}            Setup ENV to Iron Badger Staging AWS account"
    echo -e "  ${__COMMAND_COLOR__}aws.byoc.iron-badger.staging.login${NC}      Login to Iron Badger Staging AWS Account using sso"
}