# Example tshl commands

The foolowing is examples tshl of functions to login and connect to a customer's Teleport cluster and EKS cluster
- Replace the cluster names with the appropriate values for your setup

```bash
export TELEPORT_LOGIN="teleport.<domain>.com:443"


# Login to Teleport proxy for the customer
function tshl.customer-name.login() {
    export __customer_name__="Customer Name - ENV"
    export __tsh_connect_eks_cluster__="customer-name-env-eks-cluster"
    tshl.login
}

function tshl.customer-name.connect() {
    export __customer_name__="Customer Name - ENV"
    export __tsh_connect_eks_cluster__="customer-name-env-eks-cluster"
    tshl.connect
}
```