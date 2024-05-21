locals {
  yum_pattern = anytrue([
    for pattern in var.ami_patterns : startswith(var.ami_name_pattern, pattern)
  ])
}

