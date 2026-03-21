locals {
  env_status = tonumber(join(", ", split(" ", data.external.check_env.result["env_status"])))
}

locals {
  aws_secret_status = tonumber(join(", ", split(" ", data.external.locate_aws_secret.result["aws_secret_status"])))
}

locals {
  plaid_client_id = local.aws_secret_status != 0 ? join(", ", split(" ", data.external.check_env.result["plaid_client_id"])) : jsondecode(data.aws_secretsmanager_secret_version.smirk[0].secret_string)[var.client_var_name]
}

locals {
  plaid_secret = local.aws_secret_status != 0 ? join(", ", split(" ", data.external.check_env.result["plaid_secret"])) : jsondecode(data.aws_secretsmanager_secret_version.smirk[0].secret_string)[var.secret_var_name]
}
