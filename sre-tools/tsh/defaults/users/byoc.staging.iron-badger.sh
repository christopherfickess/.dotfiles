
# TSL Connections
function tshl.iron-badger.staging.login() {
    export __customer_name__="Iron Badger - Staging"
    export __tsh_connect_teleport_cluster__="${__staging_iron_badger_teleport_cluster_name__}"
    tshl.login
}

function tshl.iron-badger.staging.connect() {
    tshl.iron-badger.staging.login
    export __customer_name__="Iron Badger - Staging"
    export __tsh_connect_eks_cluster__="${__staging_iron_badger_eks_cluster_name__}"
    tshl.connect
}