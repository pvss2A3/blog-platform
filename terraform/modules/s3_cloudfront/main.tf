resource "aws_s3_bucket" "frontend" {
  bucket = "my-blog-frontend-${random_string.suffix.result}"
  tags = { Name = "BlogFrontend" }
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  index_document { suffix = "index.html" }
  error_document { key = "index.html" }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

output "s3_bucket_name" {
  value = aws_s3_bucket.frontend.bucket
}

output "s3_website_endpoint" {
  value = "http://${aws_s3_bucket.frontend.bucket}.s3-website-${var.region}.amazonaws.com"
}