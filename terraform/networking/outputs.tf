output "vpc_id" {
  value = aws_vpc.main.id
}

output "kube_cp_sub_ids" {
  value = { for sub in aws_subnet.cp : sub.cidr_block => sub.id }
}

output "kube_wk_sub_id" {
  value = aws_subnet.worker.id 
}

output "workstation_sub_id" {
  value = aws_subnet.workstation.id
}

output "sg_cp_id" {
  value = aws_security_group.cp.id
}

output "sg_wk_id" {
  value = aws_security_group.wk.id
}

output "sg_workstation_id" {
  value = aws_security_group.workstation.id
}

output "sg_lb_id" {
  value = aws_security_group.lb.id
}

output "sg_efs_id" {
  value = aws_security_group.efs.id
}

output "domain" {
  value = var.kubernetes_domain
}

output "lb_arn" {
  value = aws_lb.cp.arn
}

output "lb_dns" {
  value = aws_lb.cp.dns_name
}