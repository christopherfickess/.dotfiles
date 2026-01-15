
# Example tshl functions to login and connect to a customer's Teleport cluster and EKS cluster
# Replace the cluster names with the appropriate values for your setup
__customer_name__="Customer Name"
__tsh_customer_name_staging_teleport_cluster__="customer-staging-customer-name"
__tsh_customer_name_staging_eks_cluster__="staging-customer-name-workload"


# Login to Teleport proxy for the customer
function tshl.customer-name.login() {
    if command -v tsh &> /dev/null; then
        echo "Logging into Teleport proxy at ${TELEPORT_LOGIN} for ${__customer_name__}..."
        tsh login --proxy="${TELEPORT_LOGIN}" --auth=microsoft "${__tsh_customer_name_staging_teleport_cluster__}"
    else
        echo "Teleport CLI (tsh) is not installed. Please install it to log in."
    fi
}

function tshl.customer-name.connect() {
    if command -v tsh &> /dev/null; then
        echo "Logging into Teleport proxy at ${TELEPORT_LOGIN} for ${__customer_name__}..."
        tsh kube login "${__tsh_customer_name_staging_eks_cluster__}"
    else
        echo "Teleport CLI (tsh) is not installed. Please install it to log in."
    fi
}