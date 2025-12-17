module "ssm" {
  source     = "hazelops/ssm-parameters/aws"
  version    = "~> 1.1"
  env        = var.env
  name       = var.app_name
  parameters = var.enabled ? { for name in local.secret_names : name => "-" } : {}
}
