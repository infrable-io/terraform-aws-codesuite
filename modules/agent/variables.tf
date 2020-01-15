# -----------------------------------------------------------------------------
# OPTIONAL VARIABLES
# -----------------------------------------------------------------------------
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# -----------------------------------------------------------------------------
# REQUIRED VARIABLES
# -----------------------------------------------------------------------------
variable "source_account_id" {
  type        = string
  description = <<-EOF
  "Account ID of the AWS 'source' account. The source account is the AWS
  account that is used to orchestrate CodePipeline pipelines."
  EOF
}

variable "source_codebuild_role_name" {
  type        = string
  description = <<-EOF
  "Name of the CodeBuild service role that can assume a role in this account.
  This role exists in the 'source' AWS account, however it may assume roles in
  this and any other account that calls this module."
  EOF
}

variable "destination_codebuild_role_name" {
  type        = string
  default     = ""
  description = <<-EOF
  "Name of the CodeBuild service role that can be assumed by a role in the
  'source' account. This role must exist in an account to which you wish to
  deploy. The CodeBuild service role in the source account may assume this role
  to execute deployments.

  For single-account deployments, this variable is not used and therefore
  defaults to an empty string ("")."

  For multi-account deployments, this role is created when calling this module.
  EOF
}
