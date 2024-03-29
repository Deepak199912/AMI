# Packer Builds for Linux based Systems
This module helps to build Golden AMI based CIS Hardened AMIs bought from AWS Marketplace and used for specific purposes.

AMI Name: **ubuntu-focal-20.04-amd64-server-20210824**  

## Packer AMI Build - Prerequisites 
The following are the prerequisites avalible prior the packer build is triggred.
* Packer Security group (The inbound and outbound rules are found below)
* Packer Profile Instance Role (Packer profile requirements & Policies are found below)
* Customer managed KMS key (Maually created for now)

## Packer Security Group 

| Traffic | Rule | Description |
|:---------------|:----------------------:|:---------------------------------|
| Inbound     | within VPC CIDR        | Inbound traffic open to the VPC CIDR |
| Outbound      | open to 0.0.0.0\0    | Open to Internet |

## Packer profile Requirements
* Running EC2 as you can avoid hard coding credentials
* IAM policies can be associated with users or roles
* using a KMS key for encryption

### Packer Profile
##### Instance profile role Packer_AMI_Creation_Permissions_Role is used to give necessary permission to access AWS Resources.
| Policy name | Policy type | Description |
|:--------------------------|:-----------------------------:|:------------------------------------------------------------|
| AmazonSSMManagedInstanceCore | AWS managed policy         | Required for SSM Agent Installation |
| Packer_AMI_Creation_Permissions_Policy      | Customer managed Policy         | Customer managed policy for the packer profile requirement |

### Customer Policy Example 
#### Customer Policy 1
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Sid": "MinimalEC2packerPermissions",
            "Action": [
                "ec2:AttachVolume",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CopyImage",
                "ec2:CreateImage",
                "ec2:CreateKeypair",
                "ec2:CreateSecurityGroup",
                "ec2:CreateSnapshot",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:DeleteKeyPair",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteSnapshot",
                "ec2:DeleteVolume",
                "ec2:DeregisterImage",
                "ec2:DescribeImageAttribute",
                "ec2:DescribeImages",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceStatus",
                "ec2:DescribeRegions",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSnapshots",
                "ec2:DescribeSubnets",
                "ec2:DescribeTags",
                "ec2:DescribeVolumes",
                "ec2:DetachVolume",
                "ec2:GetPasswordData",
                "ec2:ModifyImageAttribute",
                "ec2:ModifyInstanceAttribute",
                "ec2:ModifySnapshotAttribute",
                "ec2:RegisterImage",
                "ec2:RunInstances",
                "ec2:StopInstances",
                "ec2:TerminateInstances"
            ],
            "Resource": "*"
        },
        {
            "Sid": "PackerIAMPassRole",
            "Effect": "Allow",
            "Action": [
                "iam:PassRole",
                "iam:GetInstanceProfile"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "Allowuseofthekey",
            "Effect": "Allow",
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:CreateGrant",
                "kms:DescribeKey"
            ],
            "Resource": "arn:aws:kms:eu-central-1:446102611596:key/xxx-yyy-xxx-yyy-zzz"
        }
    ]
}
```

### Customer managed KMS key - CMK for Volume Encryption
#### CMK Key  Policy 
```
{
    "Version": "2012-10-17",
    "Id": "key-consolepolicy-3",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::446102611596:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow use of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::446102611596:root",
                    "arn:aws:iam::832376775327:root",
                    "arn:aws:iam::320919209036:root"

                ]
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow attachment of persistent resources",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::446102611596:root",
                    "arn:aws:iam::832376775327:root"
                    "arn:aws:iam::320919209036:root"
                ]
            },
            "Action": [
                "kms:CreateGrant",
                "kms:ListGrants",
                "kms:RevokeGrant"
            ],
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": "true"
                }
            }
        }
    ]
}
```
#### Open Points
```
1. The OPS_Workflow sharing is not set properly , the respective accounts should be updated for sharing
2. The tags are not copied/updated in the AMI which is shared to the other account - This needs to be fixed
3. The Ansible modules used here should be tagged and the same to be ref here.
4. Change the github actions from env to var ( which allows overriding of the values in packer.yaml)
5. Change from ansible-local to ansible provisioner
```

    },
  ]

#### Build new AMI every month
```
* Building the AMI every month is enabled by configuring the scheduled trigger every month.
* A separate workflow is defined which is `CIT_Monthly_Build.yaml`.
* The scheduled trigger works only when the workflow is placed in master branch.
* The worklow for CIT monthly build is configured to checkout the develop branch, bump the patch version in version.json and push the changes to develop branch which will trigger the the CIT_Workflow and build new version of AMI and share with other accounts.
* Making changes to the `CIT_Monthly_Build.yaml` workflow will not trigger the master build as changed to this file is ignored in the `OPS_Workflow.yaml`
* If any further updates are to be done to the `CIT_Monthly_Build.yaml` workflow, update in develop branch and also the master branch.

```