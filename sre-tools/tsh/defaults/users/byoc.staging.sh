

# TSL Connections
function tshl.staging.login() {
    export __customer_name__="Internal - Staging"
    export __tsh_connect_teleport_cluster__="${__staging_internal_teleport_cluster_name__}"
    tshl.login
}

function tshl.staging.connect() {
    tshl.staging.login
    export __customer_name__="Internal - Staging"
    export __tsh_connect_eks_cluster__="${__staging_internal_eks_cluster_name__}"
    tshl.connect
}