##################################################################################
###                Resource for IAM Policy - IRSA User Portal Policy            ###
##################################################################################

resource "aws_iam_policy" "irsa_user_portal_policy" {
  name        = var.policy_name
  description = var.policy_description
  path        = var.policy_path
  policy      = var.policy

  tags = var.tags
}