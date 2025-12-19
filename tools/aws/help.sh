
function myhelp_aws() {
    echo -e "AWS Functions:"
    echo -e "------------------------------------------------------------------------------------------------------"

    if [[ ! -z "${__AWS_FILE}" ]]; then
        __myhelp_aws_sre_tools
    else 
        __myhelp_aws
    fi
    
}

function __myhelp_aws() {
    echo -e "     ${YELLOW}aws_auth_update${NC}                 - Update AWS credentials"
    echo -e "     ${YELLOW}aws_help${NC}                        - Show AWS functions help"
    echo -e "     ${YELLOW}aws_profile_switch${NC}              - Switch AWS profiles"
    echo -e "     ${YELLOW}cluster_connect${NC}                 - Connect to an EKS cluster"
    echo -e "     ${YELLOW}ec2_id_function${NC}                 - Get EC2 instance ID by name"
    echo -e "     ${YELLOW}ec2_ssm_connection${NC}              - Connect via SSM"
    echo -e "     ${YELLOW}eks_cluster_info${NC}                - Get cluster information"
    echo -e "     ${YELLOW}eks_list_clusters${NC}               - List all EKS clusters"
    echo -e "     ${YELLOW}list_kubernetes_objects${NC}         - List all Kubernetes objects in a specified namespace"
    echo -e "     ${YELLOW}list_node_group${NC}                 - List node groups for a cluster (Needs help)"
    echo -e "     ${YELLOW}ssm_parse_command_to_node_id${NC}    - Run command via SSM"
    echo -e "     ${YELLOW}tshl${NC}                            - Teleport SSH login helper"
}