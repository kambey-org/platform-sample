module "vpc_k8s" {
  source = "../../modules/vpc"

  name       = var.name
  cidr_block = var.cidr_block
  azs        = var.azs
}