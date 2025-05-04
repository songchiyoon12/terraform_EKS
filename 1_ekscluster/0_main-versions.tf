terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.31"
    }
  }
  backend "s3" {
    bucket = "my-template-026668750147"
    key    = "eks-project/terraform.tfstate"
    region = "ap-northeast-2"
  }
}


provider "aws" {
  region = var.aws_region
}


