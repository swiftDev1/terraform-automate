terraform {

#   backend "s3" {
#     bucket         = "saucecode-terraform-remote-state-backend-bucket"
#     key            = "web-app/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform_state"
#   }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.4.0"
    }
  }

}

provider "aws" {
  # Configuration options
  region = var.default_region
}