terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.9.9"
    }
    dns = { source = "hashicorp/dns" }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}
provider "dns" {
  update {
    server        = "10.10.0.246"
    key_name      = "tofu-key."
    key_algorithm = "hmac-sha256"
    key_secret    = var.tsig_secret
  }
}