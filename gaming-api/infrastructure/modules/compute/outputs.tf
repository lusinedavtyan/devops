output "alb_dns_name" {
  value = aws_lb.genesis_alb.dns_name
}

output "asg_name" {
  value = aws_autoscaling_group.genesis_asg.name
}

output "app_sg_id" {
  value = aws_security_group.app_sg.id
}
