# Creating Access Keys

Programmatic access to AWS is granted via access keys. Once you can login via the AWS Management Console, you can create your access keys.

Access key creation can be done in the AWS Management Console or via the AWS CLI.

## AWS Management Console

1. Click your username in the navigation bar, then **My Security Credentials**.

2. Under *Access keys for CLI, SDK, & API access*, click **Create access key**.

3. Download your access keys.

**Note**: If you lose your access keys, you will have to generate new ones.

4. Add your access keys to your `~/.aws/credentials` file.

`~/.aws/credentials`

```
[dwolla-operations]
aws_access_key_id = [redacted]
aws_secret_access_key = [redacted]
region=us-west-2
output=json
```

To set your `dwolla-operations` AWS profile, execute:

```bash
export AWS_PROFILE=dwolla-operations
```

This can be added as an alias to your `.bashrc` or `.zshrc` if desired:

```bash
alias aws-dwolla-operations='export AWS_PROFILE=dwolla-operations'
```

5. Test your access keys.

```bash
aws sts get-caller-identity
```

The output should contain the following:

```
{
    "UserId": "[redacted]",
    "Account": "799546647898",
    "Arn": "arn:aws:iam::799546647898:user/[redacted]"
}
```

## AWS CLI

```bash
aws iam create-access-key --user-name <user-name>
```

**Note**: You will need access keys to generate access keys.

Continue to [Creating SSH Keys](./creating-ssh-keys.md).
