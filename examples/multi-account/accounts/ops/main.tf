# -----------------------------------------------------------------------------
# DEPLOY A CI/CD PIPELINE TO THE 'OPS' AWS ACCOUNT.
# The CodePipeline pipeline is provisioned in this (ops) AWS account.
# -----------------------------------------------------------------------------
provider "aws" {
  # If Terraform fails to detect credentials inline, or in the environment, it
  # will check the AWS credentials file. The AWS credentials file must then
  # contain the following section:
  #
  # `~/.aws/credentials`
  #
  # [ops]
  # aws_access_key_id = [redacted]
  # aws_secret_access_key = [redacted]
  profile = "ops"
  region  = "us-east-1"
  version = "~> 2.44"
}

# Calling the 'agent' module allows a deployment to be made to this (ops) AWS
# Account. The 'source' CodeBuild role assumes the 'destination' CodeBuild role
# which resided in the same account and has the same permissions. This small
# operational overhead allows the implementation of multi-account
# deployments to be less complex.
module "pipeline_agent" {
  source                          = "../../../../modules/agent"
  source_account_id               = var.source_account_id
  source_codebuild_role_name      = var.source_codebuild_role_name
  destination_codebuild_role_name = var.destination_codebuild_role_name
}

module "pipeline" {
  source                          = "../../../../"
  destination_account_ids         = var.destination_account_ids
  project_name                    = "multi-account"
  destination_codebuild_role_name = var.destination_codebuild_role_name
}
