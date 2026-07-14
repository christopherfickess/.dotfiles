
# Login to Teleport proxy for Monitoring - Main
function tshl.monitoring.main.login() {
    export TELEPORT_LOGIN="${__mattermost_teleport_login__}"
    export __customer_name__="Monitoring - Main"
    export __tsh_connect_teleport_cluster__="${__monitoring_main_teleport_cluster_name__}"
    tshl.login
}

function tshl.monitoring.main.connect() {
    tshl.monitoring.main.login
    export __customer_name__="Monitoring - Main"
    export __tsh_connect_eks_cluster__="${__monitoring_main_eks_cluster_name__}"

    tshl.connect
}