##################################################################################
###                        Module: IRSA Role for User Portal                   ###
##################################################################################
module "irsa_user_portal_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version   = "~> 5.20"
  role_name = var.irsa_user_portal_role_name
  role_policy_arns = {
    irsa_user_portal_policy = data.aws_iam_policy.irsa_user_portal_policy.arn
  }
  oidc_providers = {
    main = {
      provider_arn               = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(module.eks.oidc_issuer, "https://", "")}"
      namespace_service_accounts = ["${var.app_namespace}:${var.app_service_account_name}"]
    }
  }

  tags = merge({ Name = var.irsa_user_portal_role_name }, var.tags)
}