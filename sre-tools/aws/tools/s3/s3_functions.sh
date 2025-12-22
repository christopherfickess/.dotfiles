#!/bin/bash
# ------------------
# S3 Functions
# ------------------

function s3_list_buckets() {
    echo -e "${CYAN}Listing S3 buckets...${NC}"
    aws s3 ls
}

function s3_sync_test() {
    local source="${1}"
    local destination="${2}"
    
    if [ -z "${source}" ] || [ -z "${destination}" ]; then
        echo -e "${RED}Usage: s3_sync_test <source> <destination>${NC}"
        echo -e "${YELLOW}Example: s3_sync_test ./local-folder s3://my-bucket/folder${NC}"
        return 1
    fi
    
    echo -e "${CYAN}Dry-run sync from ${source} to ${destination}...${NC}"
    aws s3 sync "${source}" "${destination}" --dryrun
}

function s3_sync_deploy() {
    local source="${1}"
    local destination="${2}"
    
    if [ -z "${source}" ] || [ -z "${destination}" ]; then
        echo -e "${RED}Usage: s3_sync_deploy <source> <destination>${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Syncing from ${source} to ${destination}...${NC}"
    aws s3 sync "${source}" "${destination}" --delete
    echo -e "${GREEN}Sync completed.${NC}"
}
