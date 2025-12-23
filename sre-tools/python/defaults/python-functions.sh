
function setup_python_env() {
    if [ -z "${1}" && ! -d "playground" ]; then 
        local __env_name="playground"
    elif [ ! -z "${1}" ]; then
         local __env_name="${1}"
    else
        echo "   ${RED}${__failed_box}${NC} Please provide a \${1} values for <env_name>"
    fi
    python -m venv "$__env_name"
    source "$__env_name/bin/activate"

    pip install --upgrade pip setuptools wheel

    if [ -f requirements.txt ]; then
        pip install -r requirements.txt
    fi
}

function disable_python_env() {
    if [ -z "${1}" && -d "playground" ]; then 
        local __env_name="playground"
    elif [ ! -z "${1}" ]; then
         local __env_name="${1}"
    else
    deactivate "${__env_name}"
}