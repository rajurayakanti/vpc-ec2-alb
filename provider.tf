terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.72.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "ap-south-1"
}

terraform {
  backend "s3" {
    bucket = "my-terraformmm-bucket-prod"
    key    = "prodfile.tfstate"
    region = "ap-south-1"
  }
}