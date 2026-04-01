
# Connect to BYOC staging iron-badger Bastion Host via SSM
function aws.byoc.iron-badger.staging() {
    echo -e "Setting AWS environment for ${CYAN}Iron Badger...${NC}"
    export AWS_PROFILE="${__staging_iron_badger_AWS_PROFILE__}"
    export AWS_DEFAULT_REGION=us-east-2
    export AWS_REGION=us-east-2
    __output_aws_connection_info__
}

function aws.byoc.iron-badger.staging.login() {
    echo -e "Logging into AWS environment for ${CYAN}Iron Badger...${NC}"
    export AWS_PROFILE="${__staging_iron_badger_sso_AWS_PROFILE__}"
    export AWS_DEFAULT_REGION=us-east-2
    export AWS_REGION=us-east-2
    aws sso login --profile "${AWS_PROFILE}"
    __output_aws_connection_info__
}

function aws.byoc.iron-badger.staging.bastion.connect(){    
    aws.byoc.iron-badger.staging

    __bastion_host_name__="${__staging_iron_badger_bastion_host_name__}"
    aws.connect.bastion "${__bastion_host_name__}"
}
