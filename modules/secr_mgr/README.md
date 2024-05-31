Checks if AWS SecretsManager object with the specified name exists.
If so, pulls the Plaid credentials from it.
Otherwize, looks for those in the local environment (~/.bash_profile)

