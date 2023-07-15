terraform {
  required_version = "~> 1.5.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.7"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }

  backend "s3" {
    bucket         = "my-app-tfstate"
    key            = "terraform.tfstate"
    dynamodb_table = "my-app-tfstate"
    region         = "ap-northeast-1"
  }
}
