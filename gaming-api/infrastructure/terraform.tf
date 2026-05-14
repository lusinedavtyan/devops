terraform {
  backend "s3" {
    bucket       = "project-genesis-tf-state-aram-20260503"
    key          = "project-genesis/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
