#!/bin/bash


environment=$1
cluster=$2

alias cloudd='cloud --server http://provisioner.internal.dev.cloud.mattermost.com'
alias cloudt='cloud --server http://provisioner.internal.test.cloud.mattermost.com'
alias clouds='cloud --server http://provisioner.internal.staging.cloud.mattermost.com'
alias cloudp='cloud --server http://provisioner.internal.prod.cloud.mattermost.com'


dev() {
  export env_tag="dev"
  export AWS_PROFILE=926412419614_AWSAdministratorAccess
  export AWS_DEFAULT_REGION=us-east-1
  export AWS_REGION=us-east-1
}
