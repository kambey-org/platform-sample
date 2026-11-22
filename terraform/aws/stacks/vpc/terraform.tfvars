name       = "vpc-k8s"
cidr_block = "10.10.0.0/16"
azs = {
  "eu-central-1a" = {
    public_cidr  = "10.10.0.0/24"
    private_cidr = "10.10.10.0/23"
  },
  "eu-central-1b" = {
    public_cidr  = "10.10.1.0/24"
    private_cidr = "10.10.12.0/23"
  }
}
