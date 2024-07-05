locals {
  time = format("%s PDT", formatdate("DD MMM YYYY hh:mm:ss", timeadd(timestamp(), "-7h")))
}

locals {
  scripts_home = fileexists("./scripts/init.sh") ? "./scripts" : "./.terraform/modules/ec2/scripts"
}
