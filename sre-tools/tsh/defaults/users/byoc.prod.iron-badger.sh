

# Login to Teleport proxy for Iron Badger
function tshl.iron-badger.prod.login() {
    export __customer_name__="Iron Badger - Prod"
    export __tsh_connect_teleport_cluster__="${__prod_iron_badger_teleport_cluster_name__}"
    tshl.login
}

function tshl.iron-badger.prod.connect() {
    tshl.iron-badger.prod.login
    export __customer_name__="Iron Badger - Prod"
    export __tsh_connect_eks_cluster__="${__prod_iron_badger_eks_cluster_name__}"

    tshl.connect
}