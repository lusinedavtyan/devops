variable "db_username" {
  type    = string
  default = "genesis_user"
}

variable "db_password" {
  type      = string
  sensitive = true
}
