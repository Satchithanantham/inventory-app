variable "app_name" {
  type = string
}
variable "tags" {
  type    = map(string)
  default = {}
}
variable "env" {
  type    = string
  default = " "
}