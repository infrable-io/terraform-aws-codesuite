# -----------------------------------------------------------------------------
# AMAZON CLOUDWATCH EVENTS ASSUME ROLE POLICY DOCUMENT
# This trust policy allows the Amazon CloudWatch Events service to assume a
# role that contains this assume role policy document.
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "events_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

# -----------------------------------------------------------------------------
# AWS CODEPIPLINE ASSUME ROLE POLICY DOCUMENT
# This trust policy allows the AWS CodePipeline service to assume a role that
# contains this assume role policy document.
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "codepipeline_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

# -----------------------------------------------------------------------------
# AWS CODEBUILD ASSUME ROLE POLICY DOCUMENT
# This trust policy allows the AWS CodeBuild service to assume a role that
# contains this assume role policy document.
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "codebuild_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

# -----------------------------------------------------------------------------
# AMAZON CLOUDWATCH EVENTS POLICY
# This policy document allows Amazon CloudWatch Events to execute a specific
# AWS CodePipeline pipeline.
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "cloudwatch_policy_document" {
  statement {
    actions = ["codepipeline:StartPipelineExecution"]

    resources = [aws_codepipeline.codepipeline_pipeline.arn]
  }
}

# -----------------------------------------------------------------------------
# AWS CODEPIPLINE POLICY DOCUMENT
# This policy document allows AWS CodePipeline to perform actions on CodeBuild,
# CodeCommit, and S3 resources. These actions represent the minimal permissions
# required to allow proper execution of AWS CodePipeline.
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "codepipeline_policy_document" {
  statement {
    actions = ["codebuild:*"]

    resources = [
      aws_codebuild_project.docker_codebuild_project.arn,
      aws_codebuild_project.build_codebuild_project.arn
    ]
  }

  # Because aws_codebuild_project.deploy_codebuild_project has a "for_each"
  # set, its attributes must be accessed on specific instances. In order to
  # accomplish this, a 'for expression' is used to determine the CodeBuild
  # project ARNs.
  statement {
    actions = ["codebuild:*"]

    resources = [for x in aws_codebuild_project.deploy_codebuild_project : x.arn]
  }

  statement {
    actions = ["codecommit:*"]

    resources = [aws_codecommit_repository.codecommit_repository.arn]
  }

  statement {
    actions = ["s3:*"]

    resources = [
      "${aws_s3_bucket.artifact_store_s3_bucket.arn}",
      "${aws_s3_bucket.artifact_store_s3_bucket.arn}/*"
    ]
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

  statement {
    actions = ["s3:*"]

    resources = [
      "${aws_s3_bucket.artifact_store_s3_bucket.arn}",
      "${aws_s3_bucket.artifact_store_s3_bucket.arn}/*"
    ]
  }

  # For single-account deployments, this statement is void, since the
  # destination_codebuild_role_name is an empty string ("").
  statement {

    actions = [
      "sts:AssumeRole",
    ]

    resources = ["arn:aws:iam::*:role/${var.destination_codebuild_role_name}"]
  }
}
