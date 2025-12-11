
export AWS_REGION="us-east-1"
export TELEPORT_VERSION="v17.7.11"

if [ "$MATTERMOST" = "TRUE" ]; then
    export MMCTL_RELEASE_VERSION="v11.1.0"
    export MMCTL_PREVIOUS_VERSION="v11.1.0"

    export MMCTL_URL="https://releases.mattermost.com/mmctl/${MMCTL_RELEASE_VERSION}/linux_amd64.tar"
    export MATTERMOST_API_URL="https://chat.mattermost.com/api/v4"
    export MATTERMOST_SITE_URL="https://chat.mattermost.com"
elif [ "$MATTERMOSTFED" = "TRUE" ]; then
    export MMCTL_RELEASE_VERSION="v11.1.0"
    export MMCTL_PREVIOUS_VERSION="v11.1.0"

    export MMCTL_URL="https://releases.mattermost.com/mmctl/${MMCTL_RELEASE_VERSION}/linux_amd64.tar"
    export MATTERMOST_API_URL="https://chat.mattermost-federation.com/api/v4"
    export MATTERMOST_SITE_URL="https://chat.mattermost-federation.com"
fi

# # Versions
