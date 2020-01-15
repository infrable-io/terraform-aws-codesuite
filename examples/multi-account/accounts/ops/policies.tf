# -----------------------------------------------------------------------------
# ADMINISTRATOR POLICY DOCUMENT
# This policy document allows an entity to perform all actions on all resources
# in an AWS account.
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "administrator_policy_document" {
  statement {
    actions = ["*"]

    resources = ["*"]
  }
}
