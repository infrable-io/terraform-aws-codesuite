# -----------------------------------------------------------------------------
# DEPLOY A CI/CD PIPELINE AGENT.
# The CodePipeline pipeline is provisioned in the 'source' AWS account.
# The 'agent' module provisions a role that may be assumed by a role in the
# source account. The 'source' role can then execute cross-account deployments
# in this account.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# AWS CODEBUILD ROLE
# This role comprises a cross-account assume role policy and required
# permissions for the service. Both the cross-account assume role policy and
# policy document for the policy associated with this role can be found in
# `policies.tf`.
# -----------------------------------------------------------------------------
resource "aws_iam_role" "codebuild_role" {
  name               = var.destination_codebuild_role_name
  assume_role_policy = data.aws_iam_policy_document.cross_account_codebuild_assume_role_policy.json
}

resource "aws_iam_role_policy" "codebuild_role_policy" {
  policy = data.aws_iam_policy_document.codebuild_policy_document.json
  role   = aws_iam_role.codebuild_role.id
}
