

function setup_mattermost_tools() {
    MM_ENABLED="TRUE"
    source_folder_scripts "${__mattermost_dir__}" "Scripts Setup"
    

    if [ -z "$MATTERMOST" ] || [ "$MATTERMOST" != "TRUE" ]; then
        return
    else
        __clone_mattermost_repo__
    fi

    ################################################
    #   TP.AUTH Bug here - breaks git autocomplete #
    ################################################
    if [ -n "$ZSH_VERSION" ]; then
        if [ -d "$HOME/git/mattermost/org-level/mm-utils" ]; then
            for i in $HOME/git/mattermost/org-level/mm-utils/scripts/*.zsh; do
                source $i;
            done
        fi
    fi
}


function __clone_mattermost_repo__() {
    # if [ -z "$MATTERMOST_REPO_URL" ]; then
    #     echo -e "${RED}MATTERMOST_REPO_URL is not set. Cannot clone repository.${NC}"
    #     return 1
    # fi
    __mm_repo_dir__="$HOME/git/mattermost/mattermost-repos"
    __mm_repo_url__="https://github.com/mattermost/mattermost.git"
    __mm_cloud_repo_url__="https://github.com/mattermost/mattermost-cloud.git"
    __mm_cloud_monitoring_repo_url__="https://github.com/mattermost/mattermost-cloud-monitoring.git"
    __mm_operator_repo_url__="https://github.com/mattermost/mattermost-operator.git"
    __mm_utils_repo_url__="https://github.com/mattermost/mm-utils.git"

    # Create mattermost directory if it doesn't exist
    if [ ! -d "$__mm_repo_dir__" ]; then
        echo -e "${GREEN}Creating mattermost directory...${NC}"
        mkdir -p "$__mm_repo_dir__"
    fi

    __clone_repo__ "$__mm_repo_url__" "$__mm_repo_dir__/mattermost"
    __clone_repo__ "$__mm_cloud_repo_url__" "$__mm_repo_dir__/mattermost-cloud"
    __clone_repo__ "$__mm_cloud_monitoring_repo_url__" "$__mm_repo_dir__/mattermost-cloud-monitoring"
    __clone_repo__ "$__mm_operator_repo_url__" "$__mm_repo_dir__/mattermost-operator"
    __clone_repo__ "$__mm_utils_repo_url__" "$__mm_repo_dir__/mm-utils"


    if [ -d "$HOME/git/mattermost/org-level/mm-utils" ]; then
        for i in $HOME/git/mattermost/org-level/mm-utils/scripts/*.zsh; do
            source $i;
        done
    fi
}

function __clone_repo__() {
    local __repo_url__="${1}"
    local __target_dir__="${2}"

    if [ -z "${__repo_url__}" ] || [ -z "${__target_dir__}" ]; then
        echo -e "${RED}Error: Repository URL and target directory must be provided.${NC}"
        return 1
    fi

    if [ ! -d "${__target_dir__}" ]; then
        echo -e "${GREEN}Cloning repository from ${__repo_url__} to ${__target_dir__}...${NC}"
        git clone "${__repo_url__}" "${__target_dir__}"
    fi
}

setup_mattermost_tools