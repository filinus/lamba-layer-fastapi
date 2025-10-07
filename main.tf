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

locals {
  the_zip = "${path.module}/lambda-layer-fastapi.zip"
}


resource "aws_lambda_layer_version" "fastapi_layer" {
  filename          = local.the_zip
  source_code_hash = filebase64sha256(local.the_zip)
  layer_name        = "fastapi-layer"
  compatible_runtimes = ["python3.9", "python3.10", "python3.11", "python3.12", "python3.13"]
  description       = "FastAPI 0.118.0 +Magnum+dependencies for AWS Lambda Python"
  compatible_architectures = ["x86_64"]
}

output "lambda_layer_arn" {
  value = aws_lambda_layer_version.fastapi_layer.arn
}

data "aws_lambda_layer_version" "fastapi_layer" {
  layer_name = "fastapi-layer"
  compatible_architecture = "x86_64"
}

output "latest_fastapi_layer_generic_arn" {
  value = data.aws_lambda_layer_version.fastapi_layer.layer_arn
}

output "latest_fastapi_layer_exact_arn" {
  value = data.aws_lambda_layer_version.fastapi_layer.arn
}



