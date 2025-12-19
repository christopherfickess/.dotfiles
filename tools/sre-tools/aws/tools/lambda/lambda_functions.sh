#!/bin/bash
# ------------------
# Lambda Testing Functions
# ------------------

function lambda_list_functions() {
    local region="${AWS_REGION:-us-east-1}"
    
    echo -e "${CYAN}Listing Lambda functions in region: ${region}...${NC}"
    aws lambda list-functions --region "${region}" \
        --query "Functions[*].[FunctionName,Runtime,LastModified]" \
        --output table
}

function lambda_invoke_test() {
    local function_name="${1}"
    local payload="${2:-{}}"
    local region="${AWS_REGION:-us-east-1}"
    
    if [ -z "${function_name}" ]; then
        echo -e "${RED}Usage: lambda_invoke_test <function-name> [payload-json]${NC}"
        return 1
    fi
    
    echo -e "${CYAN}Invoking Lambda function: ${function_name}...${NC}"
    aws lambda invoke \
        --function-name "${function_name}" \
        --payload "${payload}" \
        --region "${region}" \
        /tmp/lambda-response.json
    
    echo -e "${GREEN}Response:${NC}"
    cat /tmp/lambda-response.json | jq '.'
}

function lambda_get_logs() {
    local function_name="${1}"
    local lines="${2:-50}"
    local region="${AWS_REGION:-us-east-1}"
    
    if [ -z "${function_name}" ]; then
        echo -e "${RED}Usage: lambda_get_logs <function-name> [lines]${NC}"
        return 1
    fi
    
    local log_group="/aws/lambda/${function_name}"
    echo -e "${CYAN}Getting last ${lines} log lines for ${function_name}...${NC}"
    
    aws logs tail "${log_group}" --region "${region}" --follow=false --format short | tail -n "${lines}"
}