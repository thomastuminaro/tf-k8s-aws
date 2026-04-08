output "efs_dns" {
    value = aws_efs_mount_target.share.dns_name
}