#!/bin/bash

# This is for Mattermost Org specific bash functions and settings
# This is set in the tmp/env.sh file as MATTERMOST=TRUE



# URLs

function mmctl() {
    if ! command -v mmctl &> /dev/null; then
        echo -e "${RED}mmctl could not be found. Please install it first.${NC}"
        update_mattermost_ctl
        return 1
    else
        echo -e "${CYAN}     mmctl is installed.${NC}"
    fi
} 

function update_mattermost_ctl() {
    if [ -z "$ISWINDOWS" ] || [ "$ISWINDOWS" != "TRUE" ]; then
        echo -e "${RED}This function is only supported on Windows systems.${NC}"
        return 1
    elif [ -z "$MMCTL_PREVIOUS_VERSION" ]; then
        echo -e "${RED}MMCTL_PREVIOUS_VERSION is not set. Cannot proceed with the update.${NC}"
        return 1
    elif [ -z "$MMCTL_URL" ]; then
        echo -e "${RED}MMCTL_URL is not set. Cannot proceed with the update.${NC}"
        return 1
    elif [ -z "$MMCTL_RELEASE_VERSION" ]; then
        echo -e "${RED}MMCTL_RELEASE_VERSION is not set. Cannot proceed with the update.${NC}"
        return 1
    fi

    echo -e "${GREEN}Updating Mattermost ctl Tool...${NC}"
    pushd $HOME/bin;
        curl -vfsSL -O $MMCTL_URL > "${HOME}/bin/linux_amd64.tar" \
            && echo -e "${GREEN}Downloaded mmctl version ${MMCTL_RELEASE_VERSION}${NC}" || {
            echo -e "${RED}Failed to download mmctl from ${MMCTL_URL}${NC}"
            return 1
        };
    popd
    mkdir -p ${HOME}/tmp;

    echo -e "${MAGENTA}Backing up${NC} previous mmctl version to tmp folder..."
    mv ${HOME}/bin/mmctl ${HOME}/tmp/mmctl_${MMCTL_PREVIOUS_VERSION} || \
        echo -e "${__COMMAND_COLOR__}    No previous mmctl version found to back up.${NC}";

    echo -e "${MAGENTA}Extracting and installing${NC} the new mmctl version..."
    tar -xvf ${HOME}/bin/linux_amd64.tar -C ${HOME}/bin/

    rm ${HOME}/bin/linux_amd64.tar
    echo -e "    Mattermost ctl Tool ${GREEN}updated successfully.${NC}"
}

# ------------------
# Development and Testing Functions
# ------------------

function mattermost_docker_compose() {
    local action="${1:-up}"
    local mattermost_dir="${HOME}/git/mattermost/mattermost"
    
    if [ ! -d "${mattermost_dir}" ]; then
        echo -e "${RED}Mattermost directory not found at ${mattermost_dir}${NC}"
        echo -e "${YELLOW}Run clone_mattermost_repo first${NC}"
        return 1
    fi
    
    case "${action}" in
        up|start)
            echo -e "${GREEN}Starting Mattermost with docker-compose...${NC}"
            pushd "${mattermost_dir}" > /dev/null
            docker-compose up -d
            popd > /dev/null
            echo -e "${GREEN}Mattermost started.${NC}"
            ;;
        down|stop)
            echo -e "${YELLOW}Stopping Mattermost...${NC}"
            pushd "${mattermost_dir}" > /dev/null
            docker-compose down
            popd > /dev/null
            echo -e "${GREEN}Mattermost stopped.${NC}"
            ;;
        logs)
            pushd "${mattermost_dir}" > /dev/null
            docker-compose logs -f
            popd > /dev/null
            ;;
        restart)
            mattermost_docker_compose down
            mattermost_docker_compose up
            ;;
        ps|status)
            pushd "${mattermost_dir}" > /dev/null
            docker-compose ps
            popd > /dev/null
            ;;
        *)
            echo -e "${RED}Unknown action: ${action}${NC}"
            echo -e "Usage: mattermost_docker_compose [up|down|logs|restart|ps]"
            return 1
            ;;
    esac
}

function mattermost_test() {
    local test_type="${1:-unit}"
    local mattermost_dir="${HOME}/git/mattermost/mattermost"
    
    if [ ! -d "${mattermost_dir}" ]; then
        echo -e "${RED}Mattermost directory not found at ${mattermost_dir}${NC}"
        return 1
    fi
    
    pushd "${mattermost_dir}" > /dev/null
    
    case "${test_type}" in
        unit)
            echo -e "${CYAN}Running unit tests...${NC}"
            make test
            ;;
        integration)
            echo -e "${CYAN}Running integration tests...${NC}"
            make test-integration
            ;;
        e2e)
            echo -e "${CYAN}Running end-to-end tests...${NC}"
            make test-e2e
            ;;
        all)
            echo -e "${CYAN}Running all tests...${NC}"
            make test test-integration
            ;;
        *)
            echo -e "${RED}Unknown test type: ${test_type}${NC}"
            echo -e "Usage: mattermost_test [unit|integration|e2e|all]"
            popd > /dev/null
            return 1
            ;;
    esac
    
    popd > /dev/null
}

function mattermost_build() {
    local build_type="${1:-server}"
    local mattermost_dir="${HOME}/git/mattermost/mattermost"
    
    if [ ! -d "${mattermost_dir}" ]; then
        echo -e "${RED}Mattermost directory not found at ${mattermost_dir}${NC}"
        return 1
    fi
    
    pushd "${mattermost_dir}" > /dev/null
    
    case "${build_type}" in
        server)
            echo -e "${CYAN}Building Mattermost server...${NC}"
            make build
            ;;
        webapp)
            echo -e "${CYAN}Building Mattermost webapp...${NC}"
            cd webapp && npm run build
            ;;
        all)
            echo -e "${CYAN}Building Mattermost server and webapp...${NC}"
            make build
            cd webapp && npm run build
            ;;
        *)
            echo -e "${RED}Unknown build type: ${build_type}${NC}"
            echo -e "Usage: mattermost_build [server|webapp|all]"
            popd > /dev/null
            return 1
            ;;
    esac
    
    popd > /dev/null
    echo -e "${GREEN}Build completed.${NC}"
}

function mattermost_db_reset() {
    local mattermost_dir="${HOME}/git/mattermost/mattermost"
    
    if [ ! -d "${mattermost_dir}" ]; then
        echo -e "${RED}Mattermost directory not found at ${mattermost_dir}${NC}"
        return 1
    fi
    
    echo -e "${RED}WARNING: This will reset the Mattermost database!${NC}"
    read -p "Are you sure? (yes/no): " confirm
    if [[ "${confirm}" != "yes" ]]; then
        echo -e "${CYAN}Operation cancelled.${NC}"
        return 0
    fi
    
    pushd "${mattermost_dir}" > /dev/null
    docker-compose down -v
    docker-compose up -d db
    sleep 5
    docker-compose up -d
    popd > /dev/null
    echo -e "${GREEN}Database reset completed.${NC}"
}

function mattermost_logs_tail() {
    local service="${1:-mattermost}"
    local mattermost_dir="${HOME}/git/mattermost/mattermost"
    
    if [ ! -d "${mattermost_dir}" ]; then
        echo -e "${RED}Mattermost directory not found at ${mattermost_dir}${NC}"
        return 1
    fi
    
    pushd "${mattermost_dir}" > /dev/null
    echo -e "${CYAN}Tailing logs for ${service}...${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
    docker-compose logs -f "${service}"
    popd > /dev/null
}

function mattermost_config_check() {
    local mattermost_dir="${HOME}/git/mattermost/mattermost"
    
    if [ ! -d "${mattermost_dir}" ]; then
        echo -e "${RED}Mattermost directory not found at ${mattermost_dir}${NC}"
        return 1
    fi
    
    echo -e "${CYAN}Checking Mattermost configuration...${NC}"
    
    # Check for config file
    if [ -f "${mattermost_dir}/config/config.json" ]; then
        echo -e "${GREEN}✓${NC} Config file exists"
    else
        echo -e "${YELLOW}⚠${NC} Config file not found (will use defaults)"
    fi
    
    # Check docker-compose
    if [ -f "${mattermost_dir}/docker-compose.yml" ]; then
        echo -e "${GREEN}✓${NC} docker-compose.yml exists"
    else
        echo -e "${RED}✗${NC} docker-compose.yml not found"
    fi
    
    # Check if services are running
    pushd "${mattermost_dir}" > /dev/null
    if docker-compose ps | grep -q "Up"; then
        echo -e "${GREEN}✓${NC} Services are running"
        docker-compose ps
    else
        echo -e "${YELLOW}⚠${NC} Services are not running"
    fi
    popd > /dev/null
}

function mattermost_operator_deploy() {
    local namespace="${1:-mattermost-operator}"
    
    if ! command -v kubectl > /dev/null; then
        echo -e "${RED}kubectl not found. Please install it first.${NC}"
        return 1
    fi
    
    echo -e "${CYAN}Deploying Mattermost Operator in namespace: ${namespace}...${NC}"
    
    # Create namespace if it doesn't exist
    kubectl create namespace "${namespace}" --dry-run=client -o yaml | kubectl apply -f -
    
    # Apply operator manifests (assuming they're in the operator repo)
    local operator_dir="${HOME}/git/mattermost/mattermost-operator"
    if [ -d "${operator_dir}" ]; then
        pushd "${operator_dir}" > /dev/null
        kubectl apply -f deploy/crds/
        kubectl apply -f deploy/operator/ -n "${namespace}"
        popd > /dev/null
        echo -e "${GREEN}Mattermost Operator deployed.${NC}"
    else
        echo -e "${YELLOW}Operator directory not found. Using kubectl apply with default manifests...${NC}"
        echo -e "${YELLOW}You may need to manually apply the operator manifests.${NC}"
    fi
}

function mattermost_cloud_deploy() {
    local instance_name="${1}"
    local cloud_dir="${HOME}/git/mattermost/mattermost-cloud"
    
    if [ -z "${instance_name}" ]; then
        echo -e "${RED}Usage: mattermost_cloud_deploy <instance-name>${NC}"
        return 1
    fi
    
    if [ ! -d "${cloud_dir}" ]; then
        echo -e "${RED}Mattermost Cloud directory not found at ${cloud_dir}${NC}"
        return 1
    fi
    
    echo -e "${CYAN}Deploying Mattermost Cloud instance: ${instance_name}...${NC}"
    echo -e "${YELLOW}Note: This requires proper cloud configuration and credentials.${NC}"
    
    pushd "${cloud_dir}" > /dev/null
    # Add deployment commands here based on your cloud setup
    echo -e "${YELLOW}Cloud deployment commands should be added based on your setup.${NC}"
    popd > /dev/null
}

function mattermost_cleanup() {
    local mattermost_dir="${HOME}/git/mattermost/mattermost"
    
    echo -e "${YELLOW}Cleaning up Mattermost development environment...${NC}"
    
    if [ -d "${mattermost_dir}" ]; then
        pushd "${mattermost_dir}" > /dev/null
        docker-compose down -v
        docker system prune -f
        popd > /dev/null
    fi
    
    # Clean build artifacts
    if [ -d "${mattermost_dir}/dist" ]; then
        rm -rf "${mattermost_dir}/dist"
        echo -e "${GREEN}✓${NC} Removed dist directory"
    fi
    
    echo -e "${GREEN}Cleanup completed.${NC}"
}



# ------------------
# Secret Functions
# ------------------
