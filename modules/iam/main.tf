data "aws_caller_identity" "current" {}

resource "aws_iam_role" "vault_role" {
  name = "vault_iam_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "ec2.amazonaws.com"
            }
        },
    ]
  })
}

resource "aws_iam_role_policy" "vault_policy" {
  role = aws_iam_role.vault_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
        {
            Effect = "Allow",
            Action = [
              "ec2:DescribeInstances",
              "ec2:DescribeTags"

            ],
            Resource = "*"
        },
        {   
            Effect = "Allow",
            Action = [
              "kms:DescribeKey",
              "kms:Encrypt",
              "kms:Decrypt"
            ],
            Resource = "*"
        },
        {
          Effect = "Allow",
          Action = [
            "s3:PutObject",
            "s3:GetObject",
            "s3:DeleteObject",
            "s3:ListBucket"
          ],
          Resource = "*"
        },
        {                                          # roles to assume
          Effect = "Allow",
          Action = "sts:AssumeRole",
          Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/jenkins_s3_role"
        }
    ]
  })
}

resource "aws_iam_instance_profile" "vault_profile" {
  role = aws_iam_role.vault_role.name
}
############ Dynamic Credential Roles for Apps Managed by Vault ############
resource "aws_iam_role" "jenkins_s3_role" {
  name = "jenkins_s3_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/vault_iam_role"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "jenkins_s3_policy" {
  role = aws_iam_role.jenkins_s3_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:CreateBucket"
        ],
        Resource = "*"
      }
    ]
  }) 
}