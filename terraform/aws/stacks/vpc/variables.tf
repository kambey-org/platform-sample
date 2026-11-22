variable "name" {
  type = string
}
variable "cidr_block" {
  type = string
}
variable "azs" {
  description = "A map of availability zones with their corresponding public and private CIDR blocks. The key is the availability zone name."
  type = map(object({
    public_cidr  = string
    private_cidr = string
  }))
}