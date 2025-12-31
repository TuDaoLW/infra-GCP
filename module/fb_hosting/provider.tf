terraform {
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.0"  # Match root, added for redundency so no warning, can be reomved
    }
  }
}
