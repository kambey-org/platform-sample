output "vpc_id" {
  value = module.vpc_k8s.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc_k8s.private_subnet_ids
}

output "public_subnet_ids" {
  value = module.vpc_k8s.public_subnet_ids
}