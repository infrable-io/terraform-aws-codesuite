# Creating SSH Keys

In order to access AWS CodeCommit, you will need to set up SSH keys.

1. Generate a public and private key.

```bash
ssh-keygen -b 2048 -t rsa -N "" -f ~/.ssh/codecommit_rsa
```

**Note**: Enter a passphrase.

2. Change private key to read-only.

```bash
chmod 400 ~/.ssh/codecommit_rsa
```

3. Upload public key to AWS.

```bash
aws iam upload-ssh-public-key --user-name <user-name> --ssh-public-key-body "$(cat ~/.ssh/codecommit_rsa.pub)"
```

The output should contain the following:

```json
{
    "SSHPublicKey": {
        "UserName": "<user-name>",
        "SSHPublicKeyId": "<ssh-public-key-id>",
        "Fingerprint": "[redacted]",
        "SSHPublicKeyBody": "[redacted]",
        "Status": "Active",
        "UploadDate": "2019-12-18T15:54:02Z"
    }
}
```

4. Configure your `~/.ssh/config` file.

`~/.ssh/config`

```
Host git-codecommit.*.amazonaws.com
  User <ssh-public-key-id>
  IdentityFile ~/.ssh/codecommit_rsa
```

5. Test your connection.

```bash
ssh git-codecommit.us-east-1.amazonaws.com
```

You should receive the following messages:

```
You have successfully authenticated over SSH. You can use Git to interact with AWS CodeCommit.
```
