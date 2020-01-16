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
# This policy is applied to the CodeBuild service role defined by the 'agent'
# module. This policy should be used to grant CodeBuild the neccessary
# permissions to provision AWS resources.
# -----------------------------------------------------------------------------
resource "aws_iam_role_policy" "administrator_role_policy" {
  policy = data.aws_iam_policy_document.administrator_policy_document.json
  role   = module.pipeline_agent.codebuild_role_id
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

module "pipeline_roles" {
  source                          = "../../../../modules/roles"
  destination_codebuild_role_name = var.destination_codebuild_role_name
}

module "pipeline" {
  source                          = "../../../../"
  destination_account_ids         = var.destination_account_ids
  project_name                    = "multi-account"
  destination_codebuild_role_name = var.destination_codebuild_role_name
  # In order to prevent the duplication of CloudWatch, CodePipeline, and
  # CodeBuild service roles, these resources are extracted into the 'roles'
  # module and their ARNs are imported as variables.
  cloudwatch_role_arn   = module.pipeline_roles.cloudwatch_role_arn
  codepipeline_role_arn = module.pipeline_roles.codepipeline_role_arn
  codebuild_role_arn    = module.pipeline_roles.codebuild_role_arn
}
