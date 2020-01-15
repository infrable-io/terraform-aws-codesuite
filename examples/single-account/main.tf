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

# -----------------------------------------------------------------------------
# AWS CODEBUILD ROLE POLICY
# This policy is applied to the CodeBuild service role defined by the 'pipeine'
# module. This policy should be used to grant CodeBuild the neccessary
# permissions to provision AWS resources.
# -----------------------------------------------------------------------------
resource "aws_iam_role_policy" "administrator_role_policy" {
  policy = data.aws_iam_policy_document.administrator_policy_document.json
  role   = module.pipeline.codebuild_role_id
}

module "pipeline" {
  source = "../.."
  # The `current` key is used to designate the case in which a deployment is
  # only to be made in the current account. This is the default, however it is
  # added here for demonstration.
  destination_account_ids = { "current" : "" }
  project_name            = "single-account"
}
