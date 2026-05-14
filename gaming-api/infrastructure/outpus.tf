output "alb_dns_name" {
  value = module.compute.alb_dns_name
}

output "asg_name" {
  value = module.compute.asg_name
}

output "vpc_id" {
  value = module.networking.vpc_id
}

output "rds_endpoint" {
  value = aws_db_instance.genesis_db.endpoint
}
