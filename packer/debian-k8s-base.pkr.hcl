source "virtualbox-iso" "debian" {
  iso_url      = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.7.0-amd64-netinst.iso"
  iso_checksum = "sha256:8fde79cfc6b20a696200fc5c15219cf6d721e8feb367e9e0e33a79d1cb68fa83"
  
  guest_os_type = "Debian_64"
  cpus          = 2
  memory        = 2048
  disk_size     = 20000

  ssh_username = "ansible"
  ssh_password = "admin1"
  ssh_timeout  = "20m"

  boot_command = ["<esc><wait>", "install auto=true priority=critical preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<enter>"]
  http_directory = "http"

  shutdown_command = "sudo shutdown -P now"
  format           = "ova"
  output_directory = "output/debian-k8s-base"
}

build {
  sources = ["source.virtualbox-iso.debian"]

  provisioner "ansible" {
    playbook_file = "../ansible/kubernetes-cluster.yml"
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get clean",
      "sudo rm -f /etc/ssh/ssh_host_*"   
    ]
  }
}