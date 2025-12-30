
function setup_python_env() {
    if [ -z "${1}" && ! -d "playground" ]; then 
        local __env_name__="playground"
    elif [ ! -z "${1}" ]; then
         local __env_name__="${1}"
    else
        echo "   ${RED}${__failed_box}${NC} Please provide a \${1} values for <env_name>"
    fi
    python -m venv "$__env_name__"
    source "$__env_name__/bin/activate"

    pip install --upgrade pip setuptools wheel

    if [ -f requirements.txt ]; then
        pip install -r requirements.txt
    fi
}

function disable_python_env() {
    if [ -z "${1}" && -d "playground" ]; then 
        local __env_name__="playground"
    elif [ ! -z "${1}" ]; then
         local __env_name__="${1}"
    fi
    deactivate "${__env_name__}"
}

# tells you where you are and what kind of Python mess you are standing in.
function python_env_info() {
    if [ -z "$VIRTUAL_ENV" ]; then
        echo "No active virtual environment"
        return 1
    fi

    local __env_name__
    __env_name__="$(basename "$VIRTUAL_ENV")"

    local __python_version
    __python_version="$(python --version 2>&1)"

    local __pip_version
    __pip_version="$(pip --version | awk '{print $2}')"

    local __pkg_count
    __pkg_count="$(pip list --format=freeze | wc -l | tr -d ' ')"

    echo "Active env: $__env_name__"
    echo "Env path:  $VIRTUAL_ENV"
    echo "Python:    $__python_version"
    echo "Pip:       $__pip_version"
    echo "Packages:  $__pkg_count"
}
