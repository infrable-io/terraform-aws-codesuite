# -----------------------------------------------------------------------------
# DEPLOY A CI/CD PIPELINE USING AWS CODESUITE SERVICES.
# This Terraform module deploys the resources necessary to host a CI/CD
# pipeline on AWS. It includes the following:
#   * Source control via AWS CodeCommit
#   * Pipeline execution on updates to master
#   * Custom build and deploy Docker images
#   * Multi-account deployments
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# This module has been updated with 0.12 syntax, which means it is no longer
# compatible with any versions below 0.12.
# -----------------------------------------------------------------------------
terraform {
  required_version = ">= 0.12"
}

data "aws_caller_identity" "current" {}

# -----------------------------------------------------------------------------
# CODECOMMIT REPOSITORY
# This CodeCommit repository contains the code for the project.
# -----------------------------------------------------------------------------
resource "aws_codecommit_repository" "codecommit_repository" {
  repository_name = var.project_name
  default_branch  = "master"
}

# -----------------------------------------------------------------------------
# ECR REPOSITORY (BUILD)
# This ECR repository contains the Docker images for the 'Build' stage of the
# CodePipeline pipeline. Docker images pushed to this repository are built
# during the 'Docker' stage of the CodePipeline pipeline.
# -----------------------------------------------------------------------------
resource "aws_ecr_repository" "build_ecr_repository" {
  name                 = "${var.project_name}/build"
  image_tag_mutability = "MUTABLE"
}

# -----------------------------------------------------------------------------
# ECR REPOSITORY (DEPLOY)
# This ECR repository contains the Docker images for the 'Deploy' stage of the
# CodePipeline pipeline. Docker images pushed to this repository are built
# during the 'Docker' stage of the CodePipeline pipeline.
# -----------------------------------------------------------------------------
resource "aws_ecr_repository" "deploy_ecr_repository" {
  name                 = "${var.project_name}/deploy"
  image_tag_mutability = "MUTABLE"
}

# -----------------------------------------------------------------------------
# CLOUDWATCH EVENTS RULE
# This CloudWatch Events rule will trigger the CodePipeline pipeline to execute
# when the event pattern is matched to an event. In this case, the pipeline is
# triggered when the master branch of the CodeCommit repository is created or
# updated.
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "cloudwatch_events_rule" {
  name = "${var.project_name}-cloudwatch-events-rule"

  event_pattern = <<PATTERN
    {
      "source": ["aws.codecommit"],
      "detail-type": ["CodeCommit Repository State Change"],
      "resources": ["${aws_codecommit_repository.codecommit_repository.arn}"],
      "detail": {
        "event": ["referenceCreated", "referenceUpdated"],
        "referenceType": ["branch"],
        "referenceName": ["master"]
      }
    }
    PATTERN
}

# -----------------------------------------------------------------------------
# CLOUDWATCH EVENTS TARGET
# This CloudWatch Events target is associated with the above CloudWatch Events
# rule.
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_event_target" "cloudwatch_event_target" {
  target_id = "${var.project_name}-cloudwatch-events-rule-target"
  rule      = aws_cloudwatch_event_rule.cloudwatch_events_rule.name
  arn       = aws_codepipeline.codepipeline_pipeline.arn
  role_arn  = var.cloudwatch_role_arn
}

# -----------------------------------------------------------------------------
# S3 BUCKET (CODEPIPELINE)
# This S3 bucket contains the stored artifacts for the CodePipeline pipeline.
# NOTE: The bucket name must contain only lowercase letters, numbers, periods
# (.), and dashes (-).
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "artifact_store_s3_bucket" {
  bucket = "${var.project_name}-s3-artifact-store"
}

# -----------------------------------------------------------------------------
# CODEPIPELINE
# This CodePipeline pipline defines 4 stage types:
#   * Source
#   * Docker
#   * Build
#   * Deploy
#
# SOURCE
#   The Source stage simply pulls in the Git repository from CodeCommit.
#
# DOCKER
#   The Docker stage builds the Docker images that are to be used for the
#   subsequent Build and Deploy stages.
#
# BUILD
#   The Build stage tests and builds the contents of the CodeCommit repository.
#   This stage may also produce a build artifact that may be used in the Deploy
#   stage.
#
# DEPLOY
#   The Deploy stage (or stages) deploys the contents of the CodeCommit
#   repository or the build artifact to one or more AWS environments. The AWS
#   environments (AWS accounts) to which to deploy are specified by the
#   `destination_account_ids` variable. A Deploy stage will be created for each
#   account.
# -----------------------------------------------------------------------------
resource "aws_codepipeline" "codepipeline_pipeline" {
  name     = "${var.project_name}-codepipeline-pipeline"
  role_arn = var.codepipeline_role_arn

  artifact_store {
    location = aws_s3_bucket.artifact_store_s3_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      output_artifacts = ["SOURCE"]
      version          = "1"

      configuration = {
        BranchName           = "master"
        PollForSourceChanges = false
        RepositoryName       = aws_codecommit_repository.codecommit_repository.repository_name
      }
    }
  }

  stage {
    name = "Docker"

    action {
      name            = "Docker"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["SOURCE"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.docker_codebuild_project.name
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SOURCE"]
      output_artifacts = ["BUILD_ARTIFACT"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.build_codebuild_project.name
      }
    }
  }

  dynamic "stage" {
    for_each = var.destination_account_ids

    content {
      # If destination_account_ids = {"current" : ""}, a deployment is only to
      # be made to the current account.
      name = stage.key == "current" ? "Deploy" : "Deploy-${title(stage.key)}"

      action {
        name            = "Deploy"
        category        = "Build"
        owner           = "AWS"
        provider        = "CodeBuild"
        input_artifacts = ["SOURCE", "BUILD_ARTIFACT"]
        version         = "1"

        configuration = {
          # WARNING: The cleanest way to associate this dynamic block with the
          # correct CodeBuild project is by name. If the CodeBuild project
          # naming convention changes, this will need to be updated.
          ProjectName   = stage.key == "current" ? "${var.project_name}-deploy" : "${var.project_name}-deploy-${lower(stage.key)}"
          PrimarySource = "SOURCE"
        }
      }

    }
  }

}

# -----------------------------------------------------------------------------
# CODEBUILD (DOCKER)
# This CodeBuild project builds the Docker images that are to be used for the
# subsequent Build and Deploy stages of the CodePipeline pipeline.
# -----------------------------------------------------------------------------
resource "aws_codebuild_project" "docker_codebuild_project" {
  name         = "${var.project_name}-docker"
  service_role = var.codebuild_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }

    environment_variable {
      name  = "AWS_REGION"
      value = var.aws_region
    }

    environment_variable {
      name  = "BUILD_IMAGE_REPOSITORY"
      value = "${var.project_name}/build"
    }

    environment_variable {
      name  = "DEPLOY_IMAGE_REPOSITORY"
      value = "${var.project_name}/deploy"
    }
  }

  # TODO: This source causes repeated updates.
  # source {
  #   buildspec       = var.docker_build_spec
  #   git_clone_depth = 1
  #   type            = "CODEPIPELINE"
  # }
  source {
    buildspec           = var.docker_build_spec
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }

}

# -----------------------------------------------------------------------------
# CODEBUILD (BUILD)
# This CodeBuild project tests and builds the contents of the CodeCommit
# repository. This project may also produce a build artifact that may be used
# in the Deploy stage.
# -----------------------------------------------------------------------------
resource "aws_codebuild_project" "build_codebuild_project" {
  name         = "${var.project_name}-build"
  service_role = var.codebuild_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "${aws_ecr_repository.build_ecr_repository.repository_url}:latest"
    image_pull_credentials_type = "SERVICE_ROLE"
    type                        = "LINUX_CONTAINER"
  }

  source {
    buildspec           = var.build_build_spec
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }

}

# -----------------------------------------------------------------------------
# CODEBUILD (DEPLOY)
# This CodeBuild project deploys the contents of the CodeCommit repository or
# the build artifact produced by the Build stage. This project has the ability
# to deploy across AWS accounts using the `DESTINATION_CODEBUILD_ROLE_ARN`
# environment variable.
#
# An example of a cross-account deployment can be found in the
# `examples/multi-account` directory. Specifically, the `assume-role` script
# demostates how to assume a cross-account role.
#
# If `DESTINATION_CODEBUILD_ROLE_ARN` is empty (""), the deployment is
# executed in the current account.
#
# The following is an example of the `destination_account_ids` variable:
#
#  {
#    "operations": "<account-id>",
#    "sandbox": "<account-id>",
#    "production": "<account-id>"
#  }
# -----------------------------------------------------------------------------
resource "aws_codebuild_project" "deploy_codebuild_project" {
  for_each = var.destination_account_ids

  # If a key in `destination_account_ids` is equal to "current", the deployment
  # will be made to the current account.
  #
  # WARNING: The cleanest way to associate the correct CodeBuild project with
  # the dynamic 'stage' block of the CodePipeline resource is by name. If the
  # CodeBuild project naming convention changes, the dynamic 'stage' block will
  # need to be updated.
  name = each.key == "current" ? "${var.project_name}-deploy" : "${var.project_name}-deploy-${lower(each.key)}"

  service_role = var.codebuild_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "${aws_ecr_repository.deploy_ecr_repository.repository_url}:latest"
    image_pull_credentials_type = "SERVICE_ROLE"
    type                        = "LINUX_CONTAINER"

    environment_variable {
      name  = "PROFILE"
      value = lower(each.key)
    }

    # If a value in `destination_account_ids` is an empty string (""), the
    # deployment will be made to the current account.
    environment_variable {
      name  = "DESTINATION_CODEBUILD_ROLE_ARN"
      value = "arn:aws:iam::${each.value == "" ? data.aws_caller_identity.current.account_id : each.value}:role/${var.destination_codebuild_role_name}"
    }
  }

  source {
    buildspec           = var.deploy_build_spec
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }

}
