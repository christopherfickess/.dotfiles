
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
    __bastion_connect_host__
}


# Login to Teleport proxy for Iron Badger
function tshl.iron-badger.prod.login() {
    export __customer_name__="Iron Badger - Prod"
    export __tsh_connect_eks_cluster__="${__prod_iron_badger_eks_cluster_name__}"
    tshl.login
}

function tshl.iron-badger.prod.connect() {
    export __customer_name__="Iron Badger - Prod"
    export __tsh_connect_eks_cluster__="${__prod_iron_badger_eks_cluster_name__}"

    tshl.connect
}