##################################################################################
###                   S3 Bucket Resources Configuration                        ###
##################################################################################

# Resource for creating an S3 bucket with specified name and tags
resource "aws_s3_bucket" "secure_s3" {
  bucket = var.bucket_name

  tags = var.tags
}

# Resource to configure ownership controls for the S3 bucket, setting ownership preference to BucketOwnerPreferred
resource "aws_s3_bucket_ownership_controls" "secure_s3_ownership" {
  bucket = aws_s3_bucket.secure_s3.id
  rule {
    object_ownership = var.object_ownership
  }
}

# ACL configuration for the S3 bucket, applied after ownership controls
resource "aws_s3_bucket_acl" "secure_s3_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.secure_s3_ownership]
  bucket     = aws_s3_bucket.secure_s3.id
  acl        = var.acl
}

# Enable versioning on the S3 bucket
resource "aws_s3_bucket_versioning" "secure_s3_versioning" {
  bucket = aws_s3_bucket.secure_s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

##################################################################################
###                   S3 Bucket Encryption and Access Control                  ###
##################################################################################

data "aws_kms_alias" "aws_s3" {
  name = "alias/aws/s3"
}

# Configure server-side encryption for the S3 bucket using AWS KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "secure_s3_encryption" {
  bucket = aws_s3_bucket.secure_s3.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = data.aws_kms_alias.aws_s3.target_key_arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = false
  }
}

# Block public access settings for the S3 bucket to enhance security
resource "aws_s3_bucket_public_access_block" "secure_s3_public_access_block" {
  bucket                  = aws_s3_bucket.secure_s3.id
  block_public_acls       = var.enabled
  block_public_policy     = var.enabled
  ignore_public_acls      = var.enabled
  restrict_public_buckets = var.enabled
}

##################################################################################
###                   S3 Bucket Policy Configuration                           ###
##################################################################################

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.secure_s3.id
  policy = var.bucket_policy
}