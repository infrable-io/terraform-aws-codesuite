# IAM

Our infrastructure concerns two domains of identity and access management: *users* and *services*.

## Users

Users represent humans, computers, or actors (e.g. a Terraform user) that have a long-lived identity. Users are responsible for managing access keys. They may also assume roles, thereby gaining temporary access to additional privileges.

For users, we use the following pattern:
* All permissioning is done via managed policies†.
* Managed policies are attached to groups.
* Users are then added to groups pursuant their access level.
* Users are *not* given inline-policies.
* Users are *not* given managed policies.

The following is an example application of the above criteria:

```hcl
// Create 'admin' IAM user.
resource "aws_iam_user" "admin" {
  name = admin
}

// Create 'admin' IAM group.
resource "aws_iam_group" "admin" {
  name = "admin"
}

// Add 'admin' user to 'admin' group.
resource "aws_iam_user_group_membership" "admin_group_membership" {
  user   = admin

  groups = [aws_iam_group.admin]
}

// Create a managed policy for the 'admin' group.
resource "aws_iam_policy" "admin_access" {
  name   = "AdminAccess"
  policy = data.aws_iam_policy_document.admin_access

}

// Define the policy document for the managed policy.
data "aws_iam_policy_document" "admin_access" {
  statement {
    effect    = "Allow"
    action    = ["*"]
    resources = ["*"]
  }
}

// Attached the managed policy to the 'admin' group.
resource "aws_iam_group_policy_attachment" "admin_group_policy_attachment" {
  group      = aws_iam_group.admin
  policy_arn = aws_iam_policy.admin_access.arn
}
```

## Services

Services represent AWS integrated services. The management of a service's access keys is delegated to AWS. Services may also assume roles.

For services, we use the following pattern:
* Permissioning is done via inline policies††.
* Inline policies are attached to roles.
* Roles are assumed using the *AWS service role* model†††.
* Services can be given managed policies, however this is discouraged.

The following is an example application of the above criteria:

```hcl
// Create a service role for AWS CodeBuild.
resource "aws_iam_role" "codebuild_service_role" {
  name               = "CodeBuildServiceRole"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role_policy.json
}

// Create an inline policy for the AWS CodeBuild service role.
resource "aws_iam_role_policy" "codebuild_role_policy" {
  policy = data.aws_iam_policy_document.codebuild_policy_document.json
  role   = aws_iam_role.codebuild_service_role.id
}

// Create an assume role policy.
data "aws_iam_policy_document" "codebuild_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

// Define the policy document for the inline policy.
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
}
```

**Note**: It should be noted that the `aws_iam_policy_document` Terraform resource is used to create an inline policy for an IAM role.

## Managed vs. Inline Policies

A *managed policy* is a standalone policy that is created and administered by AWS. Standalone policy means that the policy has its own Amazon Resource Name (ARN) that includes the policy name. Managed policies are used to specify permissions for users and are therefore more broad.

An *inline policy* is a policy that's embedded in a principal entity (a user, group, or role)—that is, the policy is an inherent part of the principal entity. Inline policies are useful when maintaining a strict one-to-one relationship between a policy and the principal entity. For this reason, inline policies are used to grant a unique set of permissions to a service.

## Assume Role Policies

Using managed and inline policies in this way should be applied to roles are well. Both users and services have the ability to assume roles. User roles should not have inline policies. Instead, permissioning is done via managed policies attached to the role. This allows for easier management of user permissioning and isolates inline policies to only service roles.

## Exceptions

Although we attempt to follow the patterns provided above for users and services, there are exceptions.

### `terraform-root`

The [`AdministratorAccess`](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_job-functions.html#jf_administrator) policy is attached directly to this user.

### `TerraformRole`

`TerraformRole` is an IAM role in the `dwolla-root` account which allows any user in the `dwolla-operations` account to assume the role. The assume role policy is provided via the `assume_role_policy` argument of the `aws_iam_role` resource and is therefore not a managed policy.

† For an explanation of the differences between managed and inline policies, see this [article](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_managed-vs-inline.html).
†† This is due to the fact that these policies are extremely specific and are scoped to a particular service or task.
††† This involves attaching an assume role policy document to the service role.
