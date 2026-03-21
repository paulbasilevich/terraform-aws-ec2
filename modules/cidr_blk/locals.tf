locals {
  time = format("%s PDT", formatdate("DD MMM YYYY hh:mm:ss", timeadd(timestamp(), "-7h")))
}

locals {
  cidr_blocks = split(" ", values(data.external.my_cidr.result)[0])
}

