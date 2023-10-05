variable "namespace" {
  type = string
}

variable "image" {
  default = "eu.gcr.io/serlo-shared/athene2-dbsetup-cronjob:latest"
}

variable "node_pool" {
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
    url                  = string
    service_account_key  = string
    service_account_name = string
  })
}

variable "schedule" {
  description = "Crontab-like schedule for the cron job"
  type        = string
}
