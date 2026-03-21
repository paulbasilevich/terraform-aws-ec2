
This module checks if AWS SecretsManager object with the specified name
(retrieved from the top level terraform.tfvars file) exists.
If so, pulls the Plaid credentials from it.
Otherwize, looks for those in the local environment (~/.bash_profile).

