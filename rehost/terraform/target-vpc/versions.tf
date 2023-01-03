# # Terraform configuration block (including required_version, backend, & required_providers)
# # Terraform providers (e.g., aws, tls, etc.)

terraform {
  required_providers {
    aws = {
      version = ">= 4.40.0, < 4.41.0"
      source  = "hashicorp/aws"
    }
  }

  backend "s3" {
    region         = "eu-central-1"
    bucket         = "tf-state-capci-group4"
    key            = "mgnn-rehost.tfstate"
    dynamodb_table = "tf-state-lock-capci-group4-mgn-rehost"
    encrypt        = "true"
  }

  required_version = "~> 1.0"
}

provider "aws" {
  region = local.region
  default_tags {
    tags = merge(
      local.tags
    )
  }
}
