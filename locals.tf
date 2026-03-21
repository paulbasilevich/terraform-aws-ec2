locals {
  scripts_home = fileexists("./scripts/init.sh") ? "./scripts" : "./.terraform/modules/ec2/scripts"
}
