# New Users/Existing Users

When using these tsh login functions there are some Variables that will need to be auto populated. These variables are:

- `__customer_name__`
- `__tshl_connect_eks_cluster`
- `__tsh_connect_teleport_cluster__`

These variables are used in the `tshl.login` function to log into the correct Teleport cluster and EKS cluster. The `__customer_name__` variable is used for display purposes only.

To set these variables, you can create a new file in the `sre-tools/tsh/defaults/users.sh` directory with the name of the customer and environment. For example, if you are logging into the Staging Internal environment, you can create a file named `byoc.staging.sh` with the following content:

```bash
# TSL Connections
function tshl.staging.login() {
    export __customer_name__="Internal - Staging"
    export __tsh_connect_teleport_cluster__="${__staging_teleport_cluster_name__}"
    tshl.login
}

function tshl.staging.connect() {
    tshl.staging.login
    export __customer_name__="Internal - Staging"
    export __tsh_connect_eks_cluster__="${__staging_eks_cluster_name__}"
    tshl.connect
}
```

To hide the names of the customers and environments, you can use a hidden file in the location of your choice and source it in to the bashrc or zshrc file. For example, you can create a file named `.tsh_env_vars` with the following content:

```bash
# Customer Staging Variables
__staging_customer_name__="Staging"
__staging_teleport_cluster_name__="staging-teleport-cluster"
__staging_eks_cluster_name__="staging-eks-cluster"

# Customer Prod Variables
__prod_customer_name__="Prod"
__prod_teleport_cluster_name__="prod-teleport-cluster"
__prod_eks_cluster_name__="prod-eks-cluster"
```

Then, you can source this file in your bashrc or zshrc file:

```bash
# Source the tsh environment variables
if [ -f ~/.tsh_env_vars ]; then
    source ~/.tsh_env_vars
fi
```

