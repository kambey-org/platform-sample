variable "workers_desired_size" {
  default = 1
  type    = number
}
variable "workers_max_size" {
  default = 3
  type    = number
}
variable "workers_min_size" {
  default = 1
  type    = number
}
variable "workers_instance_types" {
  default = ["t3.medium"]
  type    = list(string)
}