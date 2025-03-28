variable "region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
  type        = string
}

variable "db_username" {
  description = "RDS database username"
  default     = "bloguser"
  type        = string
}

variable "db_password" {
  description = "RDS database password"
  sensitive   = true
  type        = string
}