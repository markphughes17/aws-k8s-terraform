# Bootstrap configuration for the Terraform remote state bucket.
#
# This configuration uses local state on purpose — it only manages the S3
# bucket that every other configuration in this project uses as its backend.
# Apply it once, then point the rest of the project at the bucket (see the
# backend snippet in the output below).

terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

variable "state_bucket_name" {
  description = "Globally unique name for the S3 bucket that stores Terraform state"
  type        = string
  default     = "aws-k8s-terraform-state-mph"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name

  # Keep the state bucket even if this configuration is destroyed.
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name    = var.state_bucket_name
    Project = "aws-k8s-terraform"
    Purpose = "terraform-remote-state"
  }
}

# Versioning lets you recover previous state files after a bad apply.
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "state_bucket_name" {
  description = "Name of the Terraform state bucket"
  value       = aws_s3_bucket.terraform_state.id
}

output "backend_config" {
  description = "Backend block to use in the rest of the project"
  value       = <<-EOT
    terraform {
      backend "s3" {
        bucket       = "${aws_s3_bucket.terraform_state.id}"
        key          = "aws-k8s-terraform/terraform.tfstate"
        region       = "eu-west-2"
        use_lockfile = true
        encrypt      = true
      }
    }
  EOT
}
