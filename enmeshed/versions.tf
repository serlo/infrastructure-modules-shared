terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 2.0"
    }
  }
}
