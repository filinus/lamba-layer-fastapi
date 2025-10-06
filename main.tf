terraform {
  required_version = ">= 1.12.2" # Ensure that the Terraform version is 1.12.2 or higher

  required_providers {
    aws = {
      source = "hashicorp/aws" # Specify the source of the AWS provider
      version = "~> 6.3.0"        # Use a version of the AWS provider that is compatible with version
    }
  }
}

provider "aws" {
  # profile/region are from env
  default_tags {
    tags = {
      "terraformed" = abspath(".")
    }
  }
}


resource "aws_lambda_layer_version" "fastapi_layer" {
  filename          = "${path.module}/lambda-layer-fastapi.zip"  # путь к локальному архиву
  layer_name        = "fastapi-layer"
  compatible_runtimes = ["python3.8", "python3.9", "python3.10", "python3.11", "python3.12", "python3.13"]
  description       = "FastAPI and dependencies for AWS Lambda Python"
}

output "lambda_layer_arn" {
  value = aws_lambda_layer_version.fastapi_layer.arn
}

