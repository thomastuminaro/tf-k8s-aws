output "vpc_id" {
  value = aws_vpc.main.id
}

output "kube_cp_sub_ids" {
  value = { for sub in aws_subnet.kubecp : sub.tags["Name"] => sub.id }
}