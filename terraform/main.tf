resource "dns_a_record_set" "node" {
  for_each  = local.node_ips
  zone      = "lab.internal."
  name      = each.key
  addresses = [each.value]
  ttl       = 60
}
resource "libvirt_volume" "node_disk" {
  for_each = var.nodes

  name     = "${each.key}.qcow2"
  pool     = libvirt_pool.k8s_pool.name
  capacity = 21474836480

  target = {
    format = { type = "qcow2" }
      permissions = {
        mode  = "0644"
        owner = "64055"   
        group = "991"    
      }
  }

  backing_store = {
    path   = libvirt_volume.base_image.path
    format = { type = "qcow2" }
  }
}
resource "libvirt_volume" "base_image" {
  name   = "debian-base-k8s.qcow2"
  pool   = libvirt_pool.k8s_pool.name
  target = {
    format = { type = "qcow2" }
    permissions = {
      mode  = "0644"
      owner = "64055"
      group = "991"
    }
  }
  create = {
    content = {
      url = "../packer/output/debian-k8s-base/debian-k8s-base.qcow2"
    }
  }
}
resource "libvirt_pool" "k8s_pool" {
  name = "k8s-images"
  type = "dir"
  target = {
    path = "/var/lib/libvirt/images/k8s"
  }
}
resource "libvirt_network" "k8s_net" {
  name      = "k8s-net"
  autostart = true

  forward = {
    mode = "nat"
  }

  bridge = {
    name = "virbr-k8s"
  }

  ips = [
    {
      family  = "ipv4"
      address = "192.168.0.1"
      prefix  = 24

      dhcp = {
        ranges = [
          {
            start = "192.168.0.10"
            end   = "192.168.0.100"
          }
        ]
      }
    }
  ]
}
resource "libvirt_domain" "node" {
  for_each = var.nodes
  name        = each.key
  type        = "kvm"
  memory      = each.value.memory
  memory_unit = "MiB"
  vcpu        = each.value.cpus
  running     = true
  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "pc"

  }
  features = {
    acpi = true
  }
  cpu = {
    mode = "host-passthrough"
  }
  devices = {
    channels = [
      {
        source = {
          unix = {
            mode = "bind"
          }
        }

        target = {
          virt_io = {
            name = "org.qemu.guest_agent.0"
          }
        }
      }
    ]
    disks = [
      {
        source = {
          volume = {
            volume = libvirt_volume.node_disk[each.key].name 
            pool   = libvirt_pool.k8s_pool.name
          }
        }
        driver = {
          name = "qemu"
          type = "qcow2"
        } 
        target = {
          dev = "vda"
          bus = "virtio"
        }
      }
    ]
    interfaces = [
      {
        source = {
          network = {
            network = libvirt_network.k8s_net.name
          }
        }
        model = {
          type = "virtio"
        }
        wait_for_ip = {
          source  = "lease"
          network = "192.168.0.1/24"
          timeout = 120
        }
      }
    ]
    graphics = [
      {
        spice = {
          autoport = true
        }
      }
    ]
    videos = [
      {
        model = {
          type = "virtio"
        }
      }
    ]
    consoles = [
      {
        target = {
          type = "serial"
          port = 0
        }
      }
    ]
  }
}

