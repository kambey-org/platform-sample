variable "nodes" {
  type = map(object({
    role   = string 
    memory = string
    cpus   = number
  }))
}