
function aws.byoc.staging() {
    echo -e "Setting AWS environment for ${CYAN}Staging Internal...${NC}"
    export AWS_PROFILE="${__staging_internal_AWS_PROFILE__}"
    export AWS_DEFAULT_REGION=us-east-2
    export AWS_REGION=us-east-2
    __output_aws_connection_info__
}

function aws.byoc.staging.login() {
    aws.dev.login
}

# function aws.byoc.staging.connect() {
#     aws.byoc.staging
#     __cluster_connect__ "${__staging_internal_eks_cluster_name__}"
# }

function aws.byoc.staging.bastion.connect() {
    aws.byoc.staging
    __bastion_host_name__="${__staging_internal_bastion_host_name__}"
    __bastion_connect_host__
}


# TSL Connections
function tshl.iron-badger.staging.login() {
    export __customer_name__="Iron Badger - Staging"
    export __tsh_connect_eks_cluster__="${__staging_iron_badger_teleport_cluster_name__}"
    tshl.login
}

function tshl.iron-badger.staging.connect() {
    export __customer_name__="Iron Badger - Staging"
    export __tsh_connect_eks_cluster__="${__staging_iron_badger_eks_cluster_name__}"
    tshl.connect
}