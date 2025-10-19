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
  fastapi_layers = {
    x86_64 = {
      zip   = "lambda-layer-fastapi-amd64.zip"
      desc  = "FastAPI + deps for x86_64"
    }
    arm64 = {
      zip   = "lambda-layer-fastapi-arm64.zip"
      desc  = "FastAPI + deps for arm64"
    }
  }
}

resource "aws_lambda_layer_version" "fastapi_layer" {
  for_each = local.fastapi_layers
  filename          = each.value.zip
  source_code_hash = filebase64sha256(each.value.zip)
  layer_name        = "fastapi-layer"
  compatible_runtimes = ["python3.10", "python3.11", "python3.12", "python3.13"]
  description       = "FastAPI 0.119.0 +Magnum+dependencies for AWS Lambda Python | ${each.key}"
  compatible_architectures = [each.key]
}

output "fastapi_layers" {
  value = {  for k, v in aws_lambda_layer_version.fastapi_layer : k => v.arn  }
}

data aws_lambda_layer_version "reverse_lookup" {
  for_each = local.fastapi_layers
  layer_name = "fastapi-layer"
  compatible_architecture = each.key
}