##########################################################################################################################################################
# Role created for kubernetes nodes
# Allow access to secretsmanager secret where workstation pub key is
##########################################################################################################################################################

resource "aws_iam_role" "kubernetes" {
  name = "kubernetes-node-role"

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
    Name = "kubernetes-node-role"
  })
}

##########################################################################################################################################################
# Policy allowing access to secrets
##########################################################################################################################################################

resource "aws_iam_policy" "allowsecretkubernetes" {
  name = "allow_kubernetes_secret_bucket"
  path = "/"
  description = "Will allow kubernetes nodes to fetch secrets from secretmanager."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Effect   = "Allow"
        Resource = [
          "${data.terraform_remote_state.workstation.outputs["secretpubkeyarn"]}",
        ]
      },
    ]
  })
}


##########################################################################################################################################################
# Attach policies to role
##########################################################################################################################################################

resource "aws_iam_role_policy_attachment" "kubernetessecret" {
  role = aws_iam_role.kubernetes.id
  policy_arn = aws_iam_policy.allowsecretkubernetes.arn
}

##########################################################################################################################################################
# Instance profile for EC2
##########################################################################################################################################################

resource "aws_iam_instance_profile" "kubernetes" {
  name = "profile-kubernetes"
  role = aws_iam_role.kubernetes.name
}