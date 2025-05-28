##################################################################################
###                    Module for IRSA User Portal IAM Policy                  ###
##################################################################################

module "irsa_user_portal" {
  source             = "../modules/iam/policy"
  policy_name        = var.irsa_user_portal_policy_name
  policy_description = var.irsa_user_portal_policy_description
  policy_path        = var.iam_role_path
  policy = templatefile(format("%s%s", path.module, "/policy_files/irsa_iam_policy.json"), {
    region = data.aws_region.current.name
  })

  tags = var.tags
}