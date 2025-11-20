#!/bin/bash

function aws_auth_update() {
    code ~/.aws/credentials
}

function list_node_group(){
    if [[ -z "${TENANT_NAME}" || -z "${ACCOUNT_NAME}" || -z "${INSTANCE}" ]]; then 
        echo -e "${RED}Not connected to a cluster. Please connect to cluster! ${NC}"
    else
        if [[ -z ${1} ]]; then
            NAME_NODE="name"
        elif [[ "${1}" == "1" ]]; then
            NAME_NODE="name"
        elif [[ "${1}" == "2" ]]; then
            NAME_NODE="name"
        elif [[ "${1}" == "3" ]]; then
            NAME_NODE="name"
        fi

        aws ec2 describe-instances \
            --filters "Name=tag:Name,Values=$NAME_NODE" "Name=instance-state-name,Values=running" \
            --query "Reservations[].Instances[] | sort_by(@, &PrivateIpAddress)[].{ID:InstanceId,Name:Tags[?Key=='Name']|[0].Value,PrivateIP:PrivateIpAddress}" \
            --output table
    fi
}

function ssm_parse_command_to_node_id(){
    if [[ -z "${1}" || -z "${2}" ]];then 
        echo -e "${RED}Add \$1 = Instance ID and \$2 = Command to run in EC2 instance!${NC}"
    else
        INSTANCE_ID=${1}
        aws ssm start-session   \
            --target $INSTANCE_ID   \
            --document-name AWS-StartNonInteractiveCommand  \
            --parameters "command=[\"$2\"]"
    fi
}


function ec2_id_function(){
    if [ -z "${1}" ];then 

        echo -e "${RED}Pass in \$1 for instance name${NCR}"
    else
        _ec2_id=$(aws ec2 describe-instances \
            --filters "Name=tag:Name,Values=${1}" \
            --query "Reservations[*].Instances[*].InstanceId" \
            --output text)

        # ec2_ssm_connection
    fi
}

function ec2_ssm_connection(){
    if [ -z "${_ec2_id}" ];then 
        echo -e "${RED}Pass ec2_id_function for instance id${NCR}"
    else
        aws ssm start-session --target ${_ec2_id}
    fi
}

