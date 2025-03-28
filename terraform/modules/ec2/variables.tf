variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "app_sg_id" {
  description = "Security group ID for the app layer"
  type        = string
}

variable "rds_endpoint" {
  description = "RDS endpoint for database connection"
  type        = string
}

variable "db_password" {
  description = "RDS database password"
  type        = string
}