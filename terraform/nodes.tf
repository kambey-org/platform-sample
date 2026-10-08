locals {
  inventory = yamldecode(file("${path.module}/../ansible/inventory.yml"))

  # {nazwa = {cpus, memory, role}}, a rolą jest nazwa grupy (master/workers)
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