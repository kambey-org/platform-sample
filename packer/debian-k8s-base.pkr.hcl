source "qemu" "debian" {
  iso_url          =  "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.7.0-amd64-netinst.iso"
  iso_checksum     = "sha256:8fde79cfc6b20a696200fc5c15219cf6d721e8feb367e9e0e33a79d1cb68fa83"

  output_directory = "output/debian-k8s-base"
  vm_name          = "debian-k8s-base.qcow2"
  format           = "qcow2"

  accelerator    = "kvm"
  machine_type   = "pc"
  cpus           = 2
  memory         = 2048
  disk_size      = "20G" 
  disk_interface = "virtio"
  net_device     = "virtio-net"
  headless       = true

  http_directory = "http"
  boot_wait      = "5s"
  boot_command = [
    "<esc><wait>",
    "auto url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
    "<enter>"
  ]

  ssh_username     = "ansible"
  ssh_password     = "tymczasowe-haslo"
  ssh_timeout      = "20m"
  shutdown_command = "sudo shutdown -P now"
}

build {
  name    = "debian-k8s-base"
  sources = ["source.qemu.debian"]

  provisioner "ansible" {
    user          = "ansible"
    playbook_file = "../ansible/k8s-pre.yaml"
    extra_arguments = [
      "--become",
      "--extra-vars",
      "ansible_python_interpreter=/usr/bin/python3"
    ]

    ansible_env_vars = ["ANSIBLE_HOST_KEY_CHECKING=False"]
  }
}