# -----------------------------------------------------------------------------
# REQUIRED VARIABLES
# -----------------------------------------------------------------------------
variable "source_account_id" {
  type        = string
  description = <<-EOF
  "Account ID of the AWS 'source' account. The source account is an AWS account
  that is used to orchestrate CodePipeline pipelines."
  EOF
}

variable "destination_account_ids" {
  type        = map(string)
  description = <<-EOF
  "Account IDs of the AWS accounts to which to deploy.

  EXAMPLES

  Multi-account

  {
    "operations": "123456789012",
    "sandbox": "123456789012",
    "production": "123456789012"
  }

  Single-account

  {
    "current": ""
  }

  If a value is an empty string (""), the deployment is executed in the current
  account. The `current` key is used to designate the case in which a
  deployment is only to be made in the current account."
  EOF
}

variable "source_codebuild_role_name" {
  type        = string
  description = <<-EOF
  "Name of the CodeBuild service role that can assume a role in this account.
  This role exists in the 'source' AWS account, however it may assume roles in
  this and other accounts."
  EOF
}

variable "destination_codebuild_role_name" {
  type        = string
  description = <<-EOF
  "Name of the CodeBuild service role that can be assumed in other accounts.
  This role must exist in an account to which you wish to deploy. The CodeBuild
  service role in the 'source' account may assume this role to execute
  deployments. For single-account deployments, this variable is not used and
  therefore defaults to an empty string ("")."
  EOF
}
