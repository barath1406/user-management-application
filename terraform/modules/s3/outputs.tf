##################################################################################
### Outputs for S3 Resources                                                   ###
##################################################################################

output "bucket_id" {
  description = "The ID of the bucket"
  value       = aws_s3_bucket.secure_s3.id
}

output "bucket_arn" {
  description = "The ARN of the bucket"
  value       = aws_s3_bucket.secure_s3.arn
}
