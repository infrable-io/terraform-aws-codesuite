# AWS CodeSuite Terraform Module

[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/infrable-io/terraform-aws-codesuite/blob/master/LICENSE)
[![Maintained by Infrable.io](https://img.shields.io/badge/Maintained%20by-Infrable.io-000000)](https://infrable.io)

A Terraform module for creating AMS CodeSuite (AWS CodeCommit, AWS CodeBuild, AWS CodeDeploy, AWS CodePipeline) infrastructure.

## Terraform Module Documentation

<!-- BEGIN_TF_DOCS -->
## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.cloudwatch_events_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.cloudwatch_event_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_codebuild_project.build_codebuild_project](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_project.deploy_codebuild_project](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_project.docker_codebuild_project](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codecommit_repository.codecommit_repository](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codecommit_repository) | resource |
| [aws_codepipeline.codepipeline_pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline) | resource |
| [aws_ecr_repository.build_ecr_repository](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.deploy_ecr_repository](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_s3_bucket.artifact_store_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to deploy to | `string` | `"us-east-1"` | no |
| <a name="input_build_build_spec"></a> [build\_build\_spec](#input\_build\_build\_spec) | Location of the buildspec.yml for the 'Build' stage. | `string` | `"codebuild/build/buildspec.yml"` | no |
| <a name="input_cloudwatch_role_arn"></a> [cloudwatch\_role\_arn](#input\_cloudwatch\_role\_arn) | The ARN of the Amazon CloudWatch Events service role. | `string` | n/a | yes |
| <a name="input_cloudwatch_role_name"></a> [cloudwatch\_role\_name](#input\_cloudwatch\_role\_name) | Name of the Amazon CloudWatch Events service role. | `string` | `"cloudwatch-events-service-role"` | no |
| <a name="input_codebuild_role_arn"></a> [codebuild\_role\_arn](#input\_codebuild\_role\_arn) | The ARN of the AWS CodeBuild service role. | `string` | n/a | yes |
| <a name="input_codebuild_role_name"></a> [codebuild\_role\_name](#input\_codebuild\_role\_name) | Name of the AWS CodeBuild service role. | `string` | `"codebuild-service-role"` | no |
| <a name="input_codepipeline_role_arn"></a> [codepipeline\_role\_arn](#input\_codepipeline\_role\_arn) | The ARN of the AWS CodePipeline service role. | `string` | n/a | yes |
| <a name="input_codepipeline_role_name"></a> [codepipeline\_role\_name](#input\_codepipeline\_role\_name) | Name of the AWS CodePipeline service role. | `string` | `"codepipeline-service-role"` | no |
| <a name="input_deploy_build_spec"></a> [deploy\_build\_spec](#input\_deploy\_build\_spec) | Location of the buildspec.yml for the 'Deploy' stage. | `string` | `"codebuild/deploy/buildspec.yml"` | no |
| <a name="input_destination_account_ids"></a> [destination\_account\_ids](#input\_destination\_account\_ids) | Account IDs of the AWS accounts to which to deploy.<br><br>EXAMPLES<br><br>**Multi-account**<pre>{"operations": "<account-id>", "sandbox": "<account-id>", "production": "<account-id>"}</pre>**Single-account**<pre>{"current": ""}</pre>If a value is an empty string (""), the deployment is executed in the current account.<br><br>The `current` key is used to designate the case in which a deployment is only to be made in the current account. | `map(string)` | <pre>{"current": ""}</pre> | no |
| <a name="input_destination_codebuild_role_name"></a> [destination\_codebuild\_role\_name](#input\_destination\_codebuild\_role\_name) | Name of the CodeBuild service role that can be assumed by a role in the 'source' account. This role must exist in an account to which you wish to deploy. The CodeBuild service role in the source account may assume this role to execute deployments.<br><br>For single-account deployments, this variable is not used and therefore defaults to an empty string ("").<br><br>For multi-account deployments, this role is created when calling the 'agent' child module. | `string` | `""` | no |
| <a name="input_docker_build_spec"></a> [docker\_build\_spec](#input\_docker\_build\_spec) | Location of the buildspec.yml for the 'Docker' stage. | `string` | `"codebuild/docker/buildspec.yml"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project. This name will be prepended to all resources that are associated with this module. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
