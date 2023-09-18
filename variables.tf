variable "name_prefix" {
  default = "devpod-pro"
}

variable "aws_region" {
  default = "us-west-2"
}

variable "az_count" {
  default = 2
}

variable "task_role_arn" {
  default = ""
}

variable "domain" {
  default = "example.com"
}

variable "hosted_zone_id" {}

variable "desired_count" {
  default = 1
}

variable "fargate_cpu" {
  default = "4096"
}

variable "fargate_memory" {
  default = "8192"
}

variable "container_port" {
  default = "8080"
}

variable "balanced_container_name" {
  default = "devpod-pro"
}

variable "app_image" {
  default = "ghcr.io/loft-sh/devpod-pro:3.3.0-alpha.22"
}
