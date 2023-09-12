
# AWS configuration
provider "aws" {
  profile = "default"
  region  = var.aws_region
}