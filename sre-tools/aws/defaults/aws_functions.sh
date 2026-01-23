#!/bin/bash

function aws_auth_update() {
    code ~/.aws/credentials
}

function aws_profile_switch(){
    if [ -z "${1}" ];then 
        while true; do
            __aws_profile_list__
            
            echo -e "${YELLOW}Enter AWS Profile to switch to: ${NC}"
            read -p "   :>  " __selected_profile__

            if grep -q "\[${__selected_profile__}\]" ~/.aws/credentials; then
                export AWS_PROFILE=${__selected_profile__}
                echo -e "${GREEN}Switched to profile: ${AWS_PROFILE}${NC}"
                break
            else
                echo -e "${RED}Profile '${__selected_profile__}' not found. Please try again.${NC}"
            fi
        done
    else
        export AWS_PROFILE=${1}
        echo -e "${GREEN}Switched to profile: ${AWS_PROFILE}${NC}"
    fi
}

function ec2_id_function(){
    if [ -z "${1}" ];then 
        echo -e "${RED}Pass in \$1 for instance name${NC}"
    else
        __ec2_id__=$(aws ec2 describe-instances \
            --filters "Name=tag:Name,Values=${1}" \
            --query "Reservations[*].Instances[*].InstanceId" \
            --output text)

        # ec2_ssm_connection
    fi
}

function eks_cluster_info(){
    if [[ "${1}" == "-p" && ! -z "${__iron_badger_eks_cluster_name}" ]]; then
        local __cluster_name__="${__iron_badger_eks_cluster_name}"
        export AWS_DEFAULT_REGION="us-east-2"
        export AWS_REGION="us-east-2"
        
    elif [[ "${1}" == "-d" || "${1}" == "--dev" && ! -z "${__dev_eks_cluster_name}" ]]; then
        local __cluster_name__="${__dev_eks_cluster_name}"
    elif [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
        __aws_eks_cluster_options__
        return
    elif [[ ! -z "${1}" ]]; then
        local __cluster_name__="${1}"
    elif [[ -z "${1}" ]]; then 
        echo -e "${RED}Add the cluster name to proceed! ${NC}"
        __aws_eks_cluster_options__
        return
    else
        __aws_eks_cluster_options__
        return
    fi
    local __cluster_name__="${__cluster_name__//[^A-Za-z0-9_-]/}"
    
    aws eks describe-cluster --name "${__cluster_name__}" --region "${AWS_REGION}" \
        --query 'cluster.{Name:name,Status:status,Endpoint:endpoint,CreatedAt:createdAt}' \
        --output table
}

function eks_list_clusters(){
    aws eks list-clusters --region "${AWS_REGION}" \
        --query 'clusters[]' \
        --output table
}

# This function needs help
function list_node_group(){
    if [[ -z "${TENANT_NAME}" || -z "${ACCOUNT_NAME}" || -z "${INSTANCE}" ]]; then 
        echo -e "${RED}Not connected to a cluster. Please connect to cluster! ${NC}"
    else
        if [[ -z ${1} ]]; then
            __node_name__="name"
        elif [[ "${1}" == "1" ]]; then
            __node_name__="name"
        elif [[ "${1}" == "2" ]]; then
            __node_name__="name"
        elif [[ "${1}" == "3" ]]; then
            __node_name__="name"
        fi

        aws ec2 describe-instances \
            --filters "Name=tag:Name,Values=$__node_name__" "Name=instance-state-name,Values=running" \
            --query "Reservations[].Instances[] | sort_by(@, &PrivateIpAddress)[].{ID:InstanceId,Name:Tags[?Key=='Name']|[0].Value,PrivateIP:PrivateIpAddress}" \
            --output table
    fi
}

function ssm_parse_command_to_node_id(){
    if [[ -z "${1}" || -z "${2}" ]];then 
        echo -e "${RED}Add \$1 = Instance ID and \$2 = Command to run in EC2 instance!${NC}"
    else
        __instance_id__=${1}
        aws ssm start-session   \
            --target $__instance_id__   \
            --document-name AWS-StartNonInteractiveCommand  \
            --parameters "command=[\"$2\"]"
    fi
}

# ------------------
# Secret Functions
# ------------------
function __aws_profile_list__(){
    echo -e "${YELLOW}Available AWS Profiles:${NC}"
    cat ~/.aws/credentials | grep "\[" | tr -d "[]"
}
