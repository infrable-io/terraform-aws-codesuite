# -----------------------------------------------------------------------------
# OPTIONAL VARIABLES
# -----------------------------------------------------------------------------
variable "cloudwatch_role_name" {
  type        = string
  default     = "cloudwatch-events-service-role"
  description = "Name of the Amazon CloudWatch Events service role."
}

variable "codepipeline_role_name" {
  type        = string
  default     = "codepipeline-service-role"
  description = "Name of the AWS CodePipeline service role."
}

variable "codebuild_role_name" {
  type        = string
  default     = "codebuild-service-role"
  description = "Name of the AWS CodeBuild service role."
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

  For multi-account deployments, this role is created when calling the 'agent'
  child module.
  EOF
}
