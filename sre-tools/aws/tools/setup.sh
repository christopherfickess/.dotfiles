#!/bin/bash

# ------------------
# SRE Tools Setup
# ------------------

# Initialize directory variables if not already set
function __source_all_aws_functions() {
    [[ -d "$__SRE_TOOLS_DIR/aws/tools/" ]] && __AWS_SRE_TOOLS_DIR="${__SRE_TOOLS_DIR}/aws/tools"
    [[ -f "$__AWS_SRE_TOOLS_DIR/cost/cost_functions.sh" ]] && source "${__AWS_SRE_TOOLS_DIR}/cost/cost_functions.sh"
    [[ -f "$__AWS_SRE_TOOLS_DIR/ec2/ec2_functions.sh" ]] && source "${__AWS_SRE_TOOLS_DIR}/ec2/ec2_functions.sh"
    [[ -f "$__AWS_SRE_TOOLS_DIR/eks/eks_functions.sh" ]] && source "${__AWS_SRE_TOOLS_DIR}/eks/eks_functions.sh"
    [[ -f "$__AWS_SRE_TOOLS_DIR/iam/iam_functions.sh" ]] && source "${__AWS_SRE_TOOLS_DIR}/iam/iam_functions.sh"
    [[ -f "$__AWS_SRE_TOOLS_DIR/lambda/lambda_functions.sh" ]] && source "${__AWS_SRE_TOOLS_DIR}/lambda/lambda_functions.sh"
    [[ -f "$__AWS_SRE_TOOLS_DIR/s3/s3_functions.sh" ]] && source "${__AWS_SRE_TOOLS_DIR}/s3/s3_functions.sh"
    [[ -f "$__AWS_SRE_TOOLS_DIR/rds/rds_functions.sh" ]] && source "${__AWS_SRE_TOOLS_DIR}/rds/rds_functions.sh"
    [[ -f "$__AWS_SRE_TOOLS_DIR/vpc/vpc_functions.sh" ]] && source "${__AWS_SRE_TOOLS_DIR}/vpc/vpc_functions.sh"
    [[ -f "$__AWS_SRE_TOOLS_DIR/sg/sg_functions.sh" ]] && source "${__AWS_SRE_TOOLS_DIR}/sg/sg_functions.sh"
}