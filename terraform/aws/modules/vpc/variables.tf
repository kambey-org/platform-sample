data "aws_availability_zones" "available" {
  state = "available"
}
variable "name" {
  type = string
}
variable "cidr_block" {
  type = string
}
variable "azs" {
  type = map(object({
    public_cidr  = string
    private_cidr = string
  }))
  validation {
    condition = length(setsubtract(
      keys(var.azs),
      data.aws_availability_zones.available.names
    )) == 0

    error_message = "Unknown AZs: ${join(", ", sort(setsubtract(keys(var.azs), data.aws_availability_zones.available.names)))}. Available: ${join(", ", data.aws_availability_zones.available.names)}."
  }
}