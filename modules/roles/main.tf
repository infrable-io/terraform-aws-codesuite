# -----------------------------------------------------------------------------
# DEPLOY CI/CD PIPELINE ROLES.
# The 'roles' module provisions the service roles that are required by the
# 'pipeline' module. This is done in order to prevent the duplication of
# CloudWatch, CodePipeline, and CodeBuild service roles when deploying multiple
# pipeline modules.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# AMAZON CLOUDWATCH EVENTS ROLE
# This role comprises an assume role policy and required permissions for the
# service. Both the assume role policy and policy document for the policy
# associated with this role can be found in `policies.tf`.
# -----------------------------------------------------------------------------
resource "aws_iam_role" "cloudwatch_role" {
  name               = var.cloudwatch_role_name
  assume_role_policy = data.aws_iam_policy_document.events_assume_role_policy.json
}

resource "aws_iam_role_policy" "cloudwatch_role_policy" {
  policy = data.aws_iam_policy_document.cloudwatch_policy_document.json
  role   = aws_iam_role.cloudwatch_role.id
}

# -----------------------------------------------------------------------------
# AWS CODEPIPELINE ROLE
# This role comprises an assume role policy and required permissions for the
# service. Both the assume role policy and policy document for the policy
# associated with this role can be found in `policies.tf`.
# -----------------------------------------------------------------------------
resource "aws_iam_role" "codepipeline_role" {
  name               = var.codepipeline_role_name
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role_policy.json
}

resource "aws_iam_role_policy" "codepipeline_role_policy" {
  policy = data.aws_iam_policy_document.codepipeline_policy_document.json
  role   = aws_iam_role.codepipeline_role.id
}

# -----------------------------------------------------------------------------
# AWS CODEBUILD ROLE
# This role comprises an assume role policy and required permissions for the
# service. Both the assume role policy and policy document for the policy
# associated with this role can be found in `policies.tf`.
# -----------------------------------------------------------------------------
resource "aws_iam_role" "codebuild_role" {
  name               = var.codebuild_role_name
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role_policy.json
}

resource "aws_iam_role_policy" "codebuild_role_policy" {
  policy = data.aws_iam_policy_document.codebuild_policy_document.json
  role   = aws_iam_role.codebuild_role.id
}
