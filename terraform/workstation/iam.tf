##########################################################################################################################################################
# Role created for workstation instance
# Allow access to S3 bucket where ansible scripts will be uploaded 
##########################################################################################################################################################

resource "aws_iam_role" "workstation" {
  name = "workstation-s3"

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
    Name = "workstation-s3"
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
# Attach policy to role
##########################################################################################################################################################

resource "aws_iam_role_policy_attachment" "workstation" {
  role = aws_iam_role.workstation.id
  policy_arn = aws_iam_policy.allowS3workstation.arn
}


##########################################################################################################################################################
# Instance profile for EC2
##########################################################################################################################################################

resource "aws_iam_instance_profile" "workstation" {
  name = "profile-workstation"
  role = aws_iam_role.workstation.name
}