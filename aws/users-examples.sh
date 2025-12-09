
# AWS Development Environment

# This is an example of how to set up your AWS development environment variables. Make sure to replace `<YOUR_AWS_PROFILE>` and `<YOUR_AWS_REGION>` with your actual AWS profile name and region.
testing_dev() {
  export env_tag="dev"
  export AWS_PROFILE="<YOUR_AWS_PROFILE>"
  export AWS_DEFAULT_REGION="<YOUR_AWS_REGION>"
  export AWS_REGION="<YOUR_AWS_REGION>"
}
