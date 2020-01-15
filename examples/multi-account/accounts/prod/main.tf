# -----------------------------------------------------------------------------
# DEPLOY A CI/CD PIPELINE AGENT TO THE 'PROD' AWS ACCOUNT.
# The CodePipeline pipeline is provisioned in the 'source' (ops) AWS account.
# The pipeline agent provisions a role that may be assumed by a role in the
# source account. This role can then execute cross-account deployments in this
# account.
# -----------------------------------------------------------------------------
provider "aws" {
  # If Terraform fails to detect credentials inline, or in the environment, it
  # will check the AWS credentials file. The AWS credentials file must then
  # contain the following section:
  #
  # `~/.aws/credentials`
  #
  # [prod]
  # aws_access_key_id = [redacted]
  # aws_secret_access_key = [redacted]
  profile = "prod"
  region  = "us-east-1"
  version = "~> 2.44"
}

module "pipeline_agent" {
  source                          = "../../../../modules/agent"
  source_account_id               = var.source_account_id
  source_codebuild_role_name      = var.source_codebuild_role_name
  destination_codebuild_role_name = var.destination_codebuild_role_name
}
