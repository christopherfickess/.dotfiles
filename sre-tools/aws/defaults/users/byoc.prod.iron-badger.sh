
# if mattermost-breakglass works change this and remove the other one
function aws.byoc.iron-badger.prod() {
    echo -e "Setting AWS environment for ${CYAN}Iron Badger...${NC}"
    export AWS_PROFILE="${__prod_iron_badger_AWS_PROFILE__}"
    export AWS_DEFAULT_REGION=us-east-2
    export AWS_REGION=us-east-2
    __output_aws_connection_info__
}

function aws.byoc.iron-badger.prod.login() {
    echo -e "Logging into AWS environment for ${CYAN}Iron Badger...${NC}"
    export AWS_PROFILE="${__prod_iron_badger_sso_AWS_PROFILE__}"
    export AWS_DEFAULT_REGION=us-east-2
    export AWS_REGION=us-east-2
    aws sso login --profile "${AWS_PROFILE}"
    __output_aws_connection_info__
}

function aws.byoc.iron-badger.prod.bastion.connect(){    
    aws.byoc.iron-badger.prod

    __bastion_host_name__="${__prod_iron_badger_bastion_host_name__}"
    aws.connect.bastion "${__bastion_host_name__}"
}
