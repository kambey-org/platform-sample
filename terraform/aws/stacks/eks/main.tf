data "terraform_remote_state" "vpcs" {
  backend = "s3"

  config = {
    bucket = "kamey-org-platform-sample-state"
    key    = "k8s-lab/aws/vpc/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "eks_k8s" {
  source                 = "../../modules/eks"
  private_subnet_ids     = data.terraform_remote_state.vpcs.outputs.private_subnet_ids
  workers_desired_size   = var.workers_desired_size
  workers_max_size       = var.workers_max_size
  workers_min_size       = var.workers_min_size
  workers_instance_types = var.workers_instance_types
}