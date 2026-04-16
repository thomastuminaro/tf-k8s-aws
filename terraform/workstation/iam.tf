##########################################################################################################################################################
# Role created for workstation instance
# Allow access to S3 bucket where ansible scripts will be uploaded 
##########################################################################################################################################################

resource "aws_iam_role" "workstation" {
  name = "workstation-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(var.common_tags, {
    Name = "workstation-role"
  })
}

##########################################################################################################################################################
# Policy allowing access to S3 bucket
##########################################################################################################################################################

resource "aws_iam_policy" "allowS3workstation" {
  name = "allow_workstation_s3_bucket"
  path = "/"
  description = "Will allow workstation to fetch scripts from s3."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.scripts.arn}" # will patch this
      },
      {
        Action = [
            "s3:GetObject"
        ]
        Effect = "Allow"
        Resource = "${aws_s3_bucket.scripts.arn}/*"
      },
      {
        Action = [
            "s3:ListAllMyBuckets"
        ]
        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}

##########################################################################################################################################################
# Policy allowing access to secrets
##########################################################################################################################################################

resource "aws_iam_policy" "allowsecretworkstation" {
  name = "allow_workstation_secret_bucket"
  path = "/"
  description = "Will allow workstation to fetch secrets from secretmanager."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Effect   = "Allow"
        Resource = [
          "${aws_secretsmanager_secret.pubkey.arn}",
          "${aws_secretsmanager_secret.privatekey.arn}"
        ]
      },
    ]
  })
}


##########################################################################################################################################################
# Attach policies to role
##########################################################################################################################################################

resource "aws_iam_role_policy_attachment" "workstations3" {
  role = aws_iam_role.workstation.id
  policy_arn = aws_iam_policy.allowS3workstation.arn
}

resource "aws_iam_role_policy_attachment" "workstationsecret" {
  role = aws_iam_role.workstation.id
  policy_arn = aws_iam_policy.allowsecretworkstation.arn
}

##########################################################################################################################################################
# Instance profile for EC2
##########################################################################################################################################################

resource "aws_iam_instance_profile" "workstation" {
  name = "profile-workstation"
  role = aws_iam_role.workstation.name
}