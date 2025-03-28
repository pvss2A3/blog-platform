output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = module.ec2.app_server_public_ip
}

output "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = module.rds.db_endpoint
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.s3_cloudfront.s3_bucket_name
}

output "s3_website_endpoint" {
  description = "S3 static website endpoint"
  value       = module.s3_cloudfront.s3_website_endpoint
}