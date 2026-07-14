
# Login to Teleport proxy for Security - Main
function tshl.security.main.login() {
    export TELEPORT_LOGIN="${__mattermost_teleport_login__}"
    export __customer_name__="Security - Main"
    export __tsh_connect_teleport_cluster__="security-main"
    tshl.login
}

function tshl.security.main.connect() {
    tshl.security.main.login
    export __customer_name__="Security - Main"
    export __tsh_connect_eks_cluster__="security-main"

    tshl.connect
}