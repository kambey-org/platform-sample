output "inventory" {
  value = {
    for name, vm in virtualbox_vm.node :
    name => {
      ip   = vm.network_adapter[0].ipv4_address
      role = var.nodes[name].role
    }
  }
}