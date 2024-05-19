# This is merely a placeholder for output.tf file
output "source" {
  description = "Path to this location"
  value       = path.module
}

output "region" {
  value = var.region
}

output "profile" {
  value = var.profile
}
