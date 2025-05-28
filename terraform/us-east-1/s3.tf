##################################################################################
###                        Module: S3 Bucket for Secure Data                   ### 
##################################################################################
module "s3_bucket" {
  source           = "../modules/s3"
  bucket_name      = "${var.bucket_name}-${data.aws_caller_identity.current.account_id}"
  acl              = var.acl
  enabled          = var.enabled
  object_ownership = var.object_ownership
  bucket_policy = templatefile(format("%s%s", path.module, "/policy_files/s3_bucket_policy.json"), {
    bucket_name = "${var.bucket_name}-${data.aws_caller_identity.current.account_id}"
    account_id  = data.aws_caller_identity.current.account_id
  })

  tags = var.tags
}