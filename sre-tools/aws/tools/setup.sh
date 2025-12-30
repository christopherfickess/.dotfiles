#!/bin/bash

# ------------------
# SRE Tools Setup
# ------------------

# Initialize directory variables if not already set
function __source_all_aws_functions() {
    [[ -d "$__sre_tools_dir__/aws/tools/" ]] && __aws_sre_tools_dir__="${__sre_tools_dir__}/aws/tools"
    [[ -f "$__aws_sre_tools_dir__/cost/cost_functions.sh" ]] && source "${__aws_sre_tools_dir__}/cost/cost_functions.sh"
    [[ -f "$__aws_sre_tools_dir__/ec2/ec2_functions.sh" ]] && source "${__aws_sre_tools_dir__}/ec2/ec2_functions.sh"
    [[ -f "$__aws_sre_tools_dir__/eks/eks_functions.sh" ]] && source "${__aws_sre_tools_dir__}/eks/eks_functions.sh"
    [[ -f "$__aws_sre_tools_dir__/iam/iam_functions.sh" ]] && source "${__aws_sre_tools_dir__}/iam/iam_functions.sh"
    [[ -f "$__aws_sre_tools_dir__/lambda/lambda_functions.sh" ]] && source "${__aws_sre_tools_dir__}/lambda/lambda_functions.sh"
    [[ -f "$__aws_sre_tools_dir__/s3/s3_functions.sh" ]] && source "${__aws_sre_tools_dir__}/s3/s3_functions.sh"
    [[ -f "$__aws_sre_tools_dir__/rds/rds_functions.sh" ]] && source "${__aws_sre_tools_dir__}/rds/rds_functions.sh"
    [[ -f "$__aws_sre_tools_dir__/vpc/vpc_functions.sh" ]] && source "${__aws_sre_tools_dir__}/vpc/vpc_functions.sh"
    [[ -f "$__aws_sre_tools_dir__/sg/sg_functions.sh" ]] && source "${__aws_sre_tools_dir__}/sg/sg_functions.sh"
}