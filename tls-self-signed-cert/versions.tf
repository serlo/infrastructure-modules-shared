terraform {
  required_version = ">= 1.0"
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.0"
    }
  }
}
