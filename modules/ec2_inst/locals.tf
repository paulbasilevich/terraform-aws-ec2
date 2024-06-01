locals {
  time = format("%s PDT", formatdate("DD MMM YYYY hh:mm:ss", timeadd(timestamp(), "-7h")))
}

locals {
  plaid_root_directory = module.key_pair.ssh_key_name
}
