terraform {
  required_version = ">= 1.10"

  required_providers {
    multipass = {
      source  = "larstobi/multipass"
      version = "~> 1.4"
    }
  }
}
