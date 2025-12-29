#!/bin/bash

# TELEPORT_LOGIN is set in the tmp/env.sh file
    # e.g., mattermost.com:443

function tshl() {
    if command -v tsh &> /dev/null; then
        echo "Logging into Teleport proxy at ${TELEPORT_LOGIN}..."
        tsh login --proxy "${TELEPORT_LOGIN}" --auth=microsoft
    else
        echo "Teleport CLI (tsh) is not installed. Please install it to log in."
    fi
}


function aws_sts_assume_role(){
    if [[ "${1}" == "-p" || "${1}" == "--palantir" && ! -z "${__palantir_aws_assume_role}" ]]; then
        SESSION_NAME="chrisfickess"
        # CREDENTIALS=$(aws sts assume-role --role-arn "$__palantir_aws_assume_role" --role-session-name "$SESSION_NAME" --output json)

        # export AWS_ACCESS_KEY_ID=$(echo $CREDENTIALS | jq -r '.Credentials.AccessKeyId')
        # export AWS_SECRET_ACCESS_KEY=$(echo $CREDENTIALS | jq -r '.Credentials.SecretAccessKey')
        # export AWS_SESSION_TOKEN=$(echo $CREDENTIALS | jq -r '.Credentials.SessionToken')
    elif [[ "${1}" == "-d" || "${1}" == "--dev" && ! -z "${__dev_aws_assume_role}" ]]; then
        SESSION_NAME="chrisfickess"    
    elif [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
        __aws_connect_options
    elif [[ -z "${1}" || -z "${2}" ]];then 
        __aws_connect_options    
    else
        ROLE_ARN=${1}
        SESSION_NAME=${2}

        CREDENTIALS=$(aws sts assume-role --role-arn "$ROLE_ARN" --role-session-name "$SESSION_NAME" --output json)

        export AWS_ACCESS_KEY_ID=$(echo $CREDENTIALS | jq -r '.Credentials.AccessKeyId')
        export AWS_SECRET_ACCESS_KEY=$(echo $CREDENTIALS | jq -r '.Credentials.SecretAccessKey')
        export AWS_SESSION_TOKEN=$(echo $CREDENTIALS | jq -r '.Credentials.SessionToken')
    fi
}

function __aws_connect_options(){
    
        echo -e "${MAGENTA}Usage:${NC} aws_sts_assume_role [Role ARN] [Session Name]"
        echo -e "       OR"
        echo -e "        aws_sts_assume_role <flags>"
        echo -e "           ${YELLOW}-r${NC}|--role      - ${CYAN}Specify the Role ARN to assume${NC}"
        echo -e "           ${YELLOW}-s${NC}|--session   - ${CYAN}Specify the Session Name for the assumed role${NC}"
        echo -e "           ${YELLOW}-c${NC}|--clear     - ${CYAN}Clear assumed role credentials from environment variables${NC}"
        echo -e "           ${YELLOW}-p${NC}|--palantir  - ${CYAN}Assume Palantir AWS role if set in env.sh${NC}"
        echo -e "           ${YELLOW}-d${NC}|--dev       - ${CYAN}Assume Dev AWS role if set in env.sh${NC}"
        echo -e "           ${YELLOW}-h${NC}|--help      - ${CYAN}Show this help message${NC}"
        echo -e "${YELLOW}This function assumes an AWS IAM role and sets the AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and AWS_SESSION_TOKEN environment variables.${NC}"
}


function aws_eks_connect_cluster(){
    if [[ ! -z "${__palantir_eks_cluster_name}" && "${1}" == "-p" || "${1}" == "--palantir" ]]; then
        palantir
        aws_sts_assume_role -p
        export __cluster_name__="${__palantir_eks_cluster_name}"

        cluster_connect
    elif [[ ! -z "${__dev_eks_cluster_name}" && "${1}" == "-d" || "${1}" == "--dev" ]]; then
        dev
        aws_sts_assume_role -d
        export __cluster_name__="${__dev_eks_cluster_name}"

        cluster_connect
    elif [[ -z "${1}" ]]; then 
        echo -e "${RED}Add the cluster name to proceed! ${NC}"
    elif [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
        echo -e "${MAGENTA}Usage:${NC} aws_eks_connect_cluster [Cluster Name]"
        echo -e "        -p|--palantir  - Assume Palantir AWS role if set in env.sh"
        echo -e "${YELLOW}This function connects to an EKS cluster by updating the kubeconfig file.${NC}"
    else
        local __cluster_name__="${1}"
        cluster_connect
    fi
}

function __output_aws_connection_info() {
    echo
    # Check if AWS account is actually connected
    __aws_output=$(aws sts get-caller-identity --query Arn --output text 2>&1)
    __aws_exit_code=$?
    
    # Check for expired token error
    if echo "$__aws_output" | grep -q "ExpiredToken"; then
        echo -e "   ${RED}✗${NC} AWS credentials have expired. Please reconnect to AWS."
        echo
        return 1
    fi
    
    # Check for other connection errors
    if [ $__aws_exit_code -ne 0 ] || [ -z "$__aws_output" ] || echo "$__aws_output" | grep -q "error\|Error\|ERROR"; then
        echo -e "   ${RED}✗${NC}   Unable to connect to AWS account. Please check your credentials."
        echo
        return
    fi
    
    # Output just the name of the user not arn
    __user_name="$__aws_output"
    # Create a green checkbox that can be used to indicate success
    __role_name=${__user_name#*/}          # remove everything up to first /
    __role_name=${__role_name%%/*}   # remove everything after next /

    __user_name=${__user_name##*/}
    __user_name="${__user_name}"


    echo -e "   Connected to Role: ${GREEN}${__check_box}   ${__role_name}${NC}"
    echo -e "             As User: ${GREEN}${__check_box}   ${__user_name}${NC}"
    echo 
}