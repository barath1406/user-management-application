module "irsa_user_portal_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version   = "~> 5.20"
  role_name = "barath-user-portal-role"
  role_policy_arns = {
    irsa_user_portal_policy = aws_iam_policy.irsa_user_portal_policy.arn
  }
  oidc_providers = {
    main = {
      provider_arn               = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/28D07152017533336CDC6F0D5C6C001A"
      namespace_service_accounts = ["default:barath-user-portal-sa"]
    }
  }

  tags = { Name = "barath-user-portal-role" }
}

data aws_caller_identity "current" {
}

data "aws_region" "current" {
}

resource "aws_iam_policy" "irsa_user_portal_policy" {
  name        = "test-policy"
  description = "IRSA policy for user portal"
  path        = "/"
  policy      = templatefile(format("%s%s", path.module, "/policy.json"), {
    region = data.aws_region.current.name
  })
}
