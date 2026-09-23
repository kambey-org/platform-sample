resource "virtualbox_vm" "node" {
  for_each = var.nodes

  name   = each.key            
  image  = "../packer/output/debian-k8s-base/debian-k8s-base.ova"
  cpus   = each.value.cpus
  memory = each.value.memory

  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }
}

resource "null_resource" "set_hostname" {
  for_each = var.nodes

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${each.key}",
      "sudo sed -i 's/127.0.1.1.*/127.0.1.1 ${each.key}/' /etc/hosts"
    ]
    connection {
      type = "ssh"
      host = virtualbox_vm.node[each.key].network_adapter[0].ipv4_address
      user = "ansible"
      private_key = file("~/.ssh/id_rsa")
    }
  }
}

