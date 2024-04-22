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
        {   Effect = "Allow",
            Action = [
              "kms:DescribeKey",
              "kms:Encrypt",
              "kms:Decrypt"
            ],
            Resource = "*"
        }
    ]
  })
}

resource "aws_iam_instance_profile" "vault_profile" {
  role = aws_iam_role.vault_role.name
}