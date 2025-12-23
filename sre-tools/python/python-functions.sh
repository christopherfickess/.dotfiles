# tells you where you are and what kind of Python mess you are standing in.
function python_env_info() {
    if [ -z "$VIRTUAL_ENV" ]; then
        echo "No active virtual environment"
        return 1
    fi

    local __env_name
    __env_name="$(basename "$VIRTUAL_ENV")"

    local __python_version
    __python_version="$(python --version 2>&1)"

    local __pip_version
    __pip_version="$(pip --version | awk '{print $2}')"

    local __pkg_count
    __pkg_count="$(pip list --format=freeze | wc -l | tr -d ' ')"

    echo "Active env: $__env_name"
    echo "Env path:  $VIRTUAL_ENV"
    echo "Python:    $__python_version"
    echo "Pip:       $__pip_version"
    echo "Packages:  $__pkg_count"
}
