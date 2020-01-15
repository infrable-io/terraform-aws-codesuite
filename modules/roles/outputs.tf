# -----------------------------------------------------------------------------
# OUTPUTS
# -----------------------------------------------------------------------------

output "cloudwatch_role_arn" {
  value       = aws_iam_role.cloudwatch_role.arn
  description = "The ARN of the Amazon CloudWatch Events service role."
}

output "codepipeline_role_arn" {
  value       = aws_iam_role.codepipeline_role.arn
  description = "The ARN of the AWS CodePipeline service role."
}

output "codebuild_role_arn" {
  value       = aws_iam_role.codebuild_role.arn
  description = "The ARN of the AWS CodeBuild service role."
}

# -----------------------------------------------------------------------------
# CODEBUILD ROLE ID
# This output is the ID of the CodeBuild service role. It can be used when
# granting permissions to CodeBuild via the `aws_iam_role_policy` resource.
#
# EXAMPLE
#
#   resource "aws_iam_role_policy" "administrator_role_policy" {
#     policy = data.aws_iam_policy_document.administrator_policy_document.json
#     role   = module.pipeline.codebuild_role_id
#   }
# -----------------------------------------------------------------------------
output "codebuild_role_id" {
  value       = aws_iam_role.codebuild_role.id
  description = "The name of the CodeBuild service role."
}
