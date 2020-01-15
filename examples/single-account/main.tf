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
# This policy is applied to the CodeBuild service role defined by the
# 'pipeine-roles' module. This policy should be used to grant CodeBuild the
# neccessary permissions to provision AWS resources.
# -----------------------------------------------------------------------------
resource "aws_iam_role_policy" "administrator_role_policy" {
  policy = data.aws_iam_policy_document.administrator_policy_document.json
  role   = module.pipeline_roles.codebuild_role_id
}

module "pipeline_roles" {
  source = "../../modules/roles"
}

module "pipeline" {
  source = "../.."
  # The `current` key is used to designate the case in which a deployment is
  # only to be made in the current account. This is the default, however it is
  # added here for demonstration.
  destination_account_ids = { "current" : "" }
  project_name            = "single-account"
  # In order to prevent the duplication of CloudWatch, CodePipeline, and
  # CodeBuild service roles, these resources are extracted into the 'roles'
  # module and their ARNs are imported as variables.
  cloudwatch_role_arn   = module.pipeline_roles.cloudwatch_role_arn
  codepipeline_role_arn = module.pipeline_roles.codepipeline_role_arn
  codebuild_role_arn    = module.pipeline_roles.codebuild_role_arn
}
