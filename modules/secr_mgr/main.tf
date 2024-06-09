module "provider" {
  source  = "../../modules/provider"
  profile = var.aws_profile
}

data "external" "locate_aws_secret" {
  program = ["bash", "${var.scripts}/find_aws_secret.sh"]
  query = {
    aws_secret_name = var.aws_secret_name
  }
}

data "external" "check_env" {
  depends_on = [data.external.locate_aws_secret]
  program    = ["bash", "${var.scripts}/check_env.sh"]
  query = {
    aws_secret_status = local.aws_secret_status
  }

  lifecycle {
    postcondition {
      condition     = tonumber(join(", ", split(" ", self.result["env_status"]))) == 0
      error_message = <<-EOT
      Insofar as "${var.aws_secret_name}" AWS SecretsManager object is currently unavailable,
      the system looks for Plaid credentials in the local profile.

      Make sure that the following environment variables are defined in ~/.bash_profile file:
      export PLAID_CLIENT_ID=<Your client ID retrieved from https://dashboard.plaid.com/developers/keys>
             (format: "^[[:xdigit:]]{24}$")
      export PLAID_SECRET=<Your "secret" retrieved from the same URI>
             (format: "^[[:xdigit:]]{30}$")
      EOT
    }
  }
}

resource "aws_secretsmanager_secret" "plaid" {
  name                    = var.aws_secret_name
  recovery_window_in_days = 0
  count                   = local.aws_secret_status != 0 ? 1 : 0
}

resource "aws_secretsmanager_secret_version" "plaid" {
  secret_id     = aws_secretsmanager_secret.plaid[0].id
  secret_string = jsonencode(tomap({ "${var.client_var_name}" = local.plaid_client_id, "${var.secret_var_name}" = local.plaid_secret }))
  count         = local.aws_secret_status != 0 ? 1 : 0
}

data "aws_secretsmanager_secret" "plaid" {
  name  = var.aws_secret_name
  count = local.aws_secret_status == 0 ? 1 : 0
}

data "aws_secretsmanager_secret_version" "plaid" {
  secret_id = data.aws_secretsmanager_secret.plaid[0].id
  count     = local.aws_secret_status == 0 ? 1 : 0
}
