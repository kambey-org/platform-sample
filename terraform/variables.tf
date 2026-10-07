variable "nodes" {
  type = map(object({
    role   = string
    memory = number
    cpus   = number
  }))
}
variable "tsig_secret" {
  type      = string
  sensitive = true
}