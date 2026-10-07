data "libvirt_domain_interface_addresses" "node" {
  for_each = var.nodes
  domain   = libvirt_domain.node[each.key].name
  source   = "agent"
}
locals {
  node_ips = {
    for name, iface in data.libvirt_domain_interface_addresses.node :
    name => iface.interfaces[1].addrs[0].addr
  }
}
output "node_ips" {
  value = local.node_ips
}

resource "local_file" "hosts_snippet" {
  filename = "${path.module}/hosts.snippet"
  content  = join("\n", [for n, ip in local.node_ips : "${ip} ${n}.lab.internal ${n}"])
}

resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/../ansible/inventory.yml"
  file_permission = "0644"
  content = yamlencode({
    all = {
      vars = {
        ansible_user            = "ansible"
        ansible_ssh_common_args = "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
      }
      children = {
        master = {
          hosts = { for n, ip in local.node_ips : n => { ansible_host = "${n}.lab.internal" } if length(regexall("master", n)) > 0 }
        }
        workers = {
          hosts = { for n, ip in local.node_ips : n => { ansible_host = "${n}.lab.internal" } if length(regexall("worker", n)) > 0 }
        }
      }
    }
  })
}