terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}
terraform {
  backend "s3" {
    bucket = "ohbster-ado-terraform-class5"
    key    = "cloudfront/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_s3_bucket" "content_bucket" {
  force_destroy = true
  bucket = "${var.name}-static"
}
resource "aws_s3_bucket" "logging_bucket" {
  force_destroy = true
  bucket = "${var.name}-logging"
}

# resource "aws_s3_bucket_public_access_block" "s3_public_block" {
#   bucket = aws_s3_bucket.bucket.id

#   block_public_acls       = false
#   block_public_policy     = false
#   ignore_public_acls      = false
#   restrict_public_buckets = false
# }


resource "aws_s3_bucket_website_configuration" "website_configuration" {
  bucket = aws_s3_bucket.content_bucket.id
  index_document {
    suffix = "index.html"
  }
  depends_on = [ aws_s3_bucket.content_bucket ]
}

resource "aws_s3_bucket_policy" "cloudfront_bucket_policy" {
  
  bucket = aws_s3_bucket.content_bucket.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "${aws_s3_bucket.content_bucket.arn}/*"
        }
    ]
})
depends_on = [ aws_s3_bucket.content_bucket ]
}
