variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "dnsimple_token" {}
variable "dnsimple_email" {
  default = "tacticalazn@gmail.com"
}
variable "chef_validation_client_name" {
  default = "terraform-validator"
}
variable "chef_validation_key" {}
variable "ssh_key" {}