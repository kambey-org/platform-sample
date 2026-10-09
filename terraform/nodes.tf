locals {
  inventory = yamldecode(file("${path.module}/../inventory.yaml"))

  nodes = merge([
    for group, g in local.inventory.all.children : {
      for name, h in g.hosts : name => {
        cpus   = h.cpus
        memory = h.memory
        role   = group
      }
    }
  ]...)
}