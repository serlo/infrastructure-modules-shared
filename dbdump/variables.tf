variable "image" {
  type = string
}

variable "namespace" {
  type = string
}

variable "node_pool" {
  type = string
}

variable "schedule" {
  type = string
}

variable "mysql" {
  type = object({
    host     = string
    username = string
    password = string
  })
}

variable "postgres" {
  type = object({
    host     = string
    password = string
  })
}

variable "bucket" {
  type = object({
    url                 = string
    service_account_key = string
  })
}
