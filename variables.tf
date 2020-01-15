# -----------------------------------------------------------------------------
# OPTIONAL VARIABLES
# -----------------------------------------------------------------------------
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "destination_account_ids" {
  type        = map(string)
  default     = { "current" : "" }
  description = <<-EOF
  "Account IDs of the AWS accounts to which to deploy.

  EXAMPLES

  Multi-account

    {
      "operations": "<accound-id>",
      "sandbox": "<accound-id>",
      "production": "<accound-id>"
    }

  Single-account

    {
      "current": ""
    }

  If a value is an empty string (""), the deployment is executed in the current
  account.

  The `current` key is used to designate the case in which a deployment is only
  to be made in the current account."
  EOF
}

variable "docker_build_spec" {
  type        = string
  default     = "codebuild/docker/buildspec.yml"
  description = "Location of the buildspec.yml for the 'Docker' stage."
}

variable "build_build_spec" {
  type        = string
  default     = "codebuild/build/buildspec.yml"
  description = "Location of the buildspec.yml for the 'Build' stage."
}

variable "deploy_build_spec" {
  type        = string
  default     = "codebuild/deploy/buildspec.yml"
  description = "Location of the buildspec.yml for the 'Deploy' stage."
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

# -----------------------------------------------------------------------------
# REQUIRED VARIABLES
# -----------------------------------------------------------------------------
variable "project_name" {
  type        = string
  description = <<-EOF
  "Name of the project. This name will be prepended to all resources that are
  associated with this module."
  EOF
}
