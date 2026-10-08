data "libvirt_domain_interface_addresses" "node" {
  for_each = local.nodes
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