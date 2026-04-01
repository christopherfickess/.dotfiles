
function aws.get.ec2.id(){
    if [ -z "${1}" ];then 
        echo -e "${RED}Pass in \$1 for instance name${NC}"
    else
        __ec2_id__=$(aws ec2 describe-instances \
            --filters "Name=tag:Name,Values=${1}" \
            --query "Reservations[*].Instances[*].InstanceId" \
            --output text)
        echo -e "${YELLOW}${1}: ${__ec2_id__}${NC}"
    fi
}

function aws.get.ec2.info(){
    if [ -z "${1}" ];then 
        echo -e "${RED}Pass in \$1 for instance name${NC}"
    else
        __ec2_info__=$(aws ec2 describe-instances \
            --filters "Name=tag:Name,Values=${1}")
    fi
    echo "$__ec2_info__"
}

function aws.get.eks_cluster.id(){ 
    if [[ -z "${1}" ]]; then 
        echo -e "${RED}Add the cluster name to proceed! ${NC}"
    else
        __cluster_id__=$(aws eks describe-cluster --name "${1}" --region "${AWS_REGION}" --query 'cluster.arn' --output text)
        echo -e "${YELLOW}${1}: ${__cluster_id__}${NC}"
    fi
}

function aws.get.eks_cluster.info(){
    if [[ -z "${1}" ]]; then 
        echo -e "${RED}Add the cluster name to proceed! ${NC}"
    else
        __cluster_info__=$(aws eks describe-cluster --name "${1}" --region "${AWS_REGION}")
    fi
    echo "$__cluster_info__"
}


function aws.get.eks_cluster.status(){
    if [[ -z "${1}" ]]; then 
        echo -e "${RED}Add the cluster name to proceed! ${NC}"
    else
        __cluster_status__=$(aws eks describe-cluster --name "${1}" --region "${AWS_REGION}" --query 'cluster.status' --output text)
    fi
}

function aws.get.rds_cluster.id(){
    if [[ -z "${1}" ]]; then 
        echo -e "${RED}Add the cluster name to proceed! ${NC}"
    else
        __rds_cluster_id__=$(aws rds describe-db-clusters --db-cluster-identifier "${1}" --region "${AWS_REGION}" --query 'DBClusters[*].DBClusterIdentifier' --output text)
    fi
    echo -e "${YELLOW}${1}: ${__rds_cluster_id__}${NC}"
}

function aws.get.rds_cluster.info(){
    if [[ -z "${1}" ]]; then 
        echo -e "${RED}Add the cluster name to proceed! ${NC}"
    else
        __rds_cluster_info__=$(aws rds describe-db-clusters --db-cluster-identifier "${1}" --region "${AWS_REGION}")
    fi
    echo "$__rds_cluster_info__"
}

function aws.get.s3_bucket.id(){
    if [[ -z "${1}" ]]; then 
        echo -e "${RED}Add the bucket name to proceed! ${NC}"
    else
        __s3_bucket_id__=$(aws s3api list-buckets --query "Buckets[?Name=='${1}'].Name" --output text)
    fi

    echo -e "${YELLOW}${1}: ${__s3_bucket_id__}${NC}"
}

function aws.get.s3_bucket.info(){
    if [[ -z "${1}" ]]; then 
        echo -e "${RED}Add the bucket name to proceed! ${NC}"
    else
        __s3_bucket_info__=$(aws s3api get-bucket-location --bucket "${1}" --region "${AWS_REGION}")
    fi
    echo "$__s3_bucket_info__"
}
