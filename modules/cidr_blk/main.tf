module "provider" {
  source  = "../../modules/provider"
  profile = var.aws_profile
}

data "external" "check_env" {
  program = ["bash", "${path.module}/check_env.sh"]
  query = {
    env_status = var.env_status
  }
}

data "external" "my_cidr" {
  program = ["bash", "${path.module}/my_cidr.sh"]
  query = {
    cidr_scope = var.cidr_scope
    extra_cidr = var.extra_cidr
  }

  lifecycle {
    precondition {
      condition     = local.env_status == 0
      error_message = <<-EOT
      Make sure that the following environment variables are defined in ~/.bash_profile file:
      export PLAID_CLIENT_ID=<Your client ID retrieved from https://dashboard.plaid.com/developers/keys>
             (format: "^[[:xdigit:]]{24}$")
      export PLAID_SECRET=<Your "secret" retrieved from the same URI>
             (format: "^[[:xdigit:]]{30}$")
      EOT
    }
  }
}

