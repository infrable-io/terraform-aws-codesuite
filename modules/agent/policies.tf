# -----------------------------------------------------------------------------
# CROSS ACCOUNT ASSUME ROLE POLICY DOCUMENT
# This trust policy allows the CodeBuild role in the 'source' account to assume
# a role in this account that contains this assume role policy document.
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "cross_account_codebuild_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      # This role must already exist in the 'source' account or the following
      # error is returned on `terraform apply`:
      #
      # Error: Error creating IAM Role [...]: MalformedPolicyDocument: Invalid
      # principal in policy: [...]
      identifiers = ["arn:aws:iam::${var.source_account_id}:role/${var.source_codebuild_role_name}"]
    }
  }
}

# -----------------------------------------------------------------------------
# AWS CODEBUILD POLICY DOCUMENT
# This policy document allows AWS CodeBuild to perform actions on Amazon ECR,
# CloudWatch Logs, and S3 resources. These actions represent the minimal
# permissions required to allow proper execution of AWS CodeBuild.
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "codebuild_policy_document" {
  statement {
    actions = ["ecr:*"]

    resources = ["*"]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DeleteLogGroup",
      "logs:PutLogEvents"
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}
