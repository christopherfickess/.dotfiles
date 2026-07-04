
function aws.list.ec2_instances(){
    aws ec2 describe-instances --region "${AWS_REGION}" \
        --query 'Reservations[].Instances[].{ID:InstanceId,Type:InstanceType,State:State.Name,Name:Tags[?Key==`Name`].Value|[0]}' \
        --output table
}

function aws.list.eks_clusters(){
    aws eks list-clusters --region "${AWS_REGION}" \
        --query 'clusters[]' \
        --output table
}

function aws.list.rds_clusters(){
    aws rds describe-db-clusters --region "${AWS_REGION}" \
        --query 'DBClusters[].{ID:DBClusterIdentifier,Status:Status,Endpoint:Endpoint}' \
        --output table
}
