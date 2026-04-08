resource "aws_efs_file_system" "share" {
  creation_token = "ansible-scripts"

  tags = merge(var.common_tags, {
    Name = "ansible-scripts"
  })
}

resource "aws_efs_backup_policy" "share" {
  file_system_id = aws_efs_file_system.share.id

  backup_policy {
    status = "DISABLED"
  }
}

resource "aws_efs_mount_target" "share" {
  file_system_id = aws_efs_file_system.share.id
  subnet_id = data.terraform_remote_state.networking.outputs["workstation_sub_id"]
  security_groups = [ data.terraform_remote_state.networking.outputs["sg_efs_id"] ]
}

/* data "aws_iam_policy_document" "policy" {
  statement {
    sid    = "Allow from workstation"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:ec2:eu-west-3:247625421810:*"]
    }

    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
    ]

    resources = [aws_efs_file_system.share.arn]
  }
}

resource "aws_efs_file_system_policy" "share" {
  file_system_id = aws_efs_file_system.share.id
  policy = data.aws_iam_policy_document.policy.json
} */