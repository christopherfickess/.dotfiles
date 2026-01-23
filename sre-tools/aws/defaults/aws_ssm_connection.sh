
# Assume an AWS IAM role and set temporary credentials
function aws_sts_assume_role(){
    if [[ "${1}" == "-d" || "${1}" == "--dev" && ! -z "${__dev_aws_assume_role}" ]]; then
        dev
        __session_name__="christopher.fickess@mattermost.com"

        __check_role_arn__="${__dev_aws_assumed_role}/${__session_name__}"
    elif [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
        __aws_connect_options__
        return
    elif [[ -z "${1}" || -z "${2}" ]];then 
        __aws_connect_options__
        return
    elif [[ ! -z "${1}" && ! -z "${2}" ]]; then
        __role_arn__=${1}
        __session_name__=${2}

        __credentials__=$(aws sts assume-role --role-arn "$__role_arn__" --role-session-name "$__session_name__" --output json)
        
        export AWS_ACCESS_KEY_ID=$(echo $__credentials__ | jq -r '.Credentials.AccessKeyId')
        export AWS_SECRET_ACCESS_KEY=$(echo $__credentials__ | jq -r '.Credentials.SecretAccessKey')
        export AWS_SESSION_TOKEN=$(echo $__credentials__ | jq -r '.Credentials.SessionToken')

        __check_role_arn__="${__role_arn__}/${__session_name__}"
    else
        __aws_connect_options__
        return
    fi

    __check_connection__=$(aws sts get-caller-identity \
        --query 'Arn' \
        --output text)

    if [[ "${__check_role_arn__}" == "${__check_connection__}" ]]; then 
        __output_aws_connection_info__
    else
        echo -e "   ${RED}${__failed_box}${NC}   Roles do not match."
        echo -e "       Expected: ${YELLOW}${__check_role_arn__}${NC}"
        echo -e "       Got:      ${YELLOW}${__check_connection__}${NC}"
        echo
    fi

}

function ec2.ssm.connection(){
    if [ -z "${_ec2_id}" ];then 
        echo -e "${RED}Pass ec2_id_function for instance id${NC}"
    else
        aws ssm start-session --target ${_ec2_id}
    fi
}