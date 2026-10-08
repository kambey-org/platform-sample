terraform {
  backend "s3" {
    bucket       = "kamey-org-platform-sample-state"
    key          = "k8s-lab/terraform.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true
  }
}