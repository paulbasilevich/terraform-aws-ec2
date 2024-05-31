Hosted here are helper scripts for enhancing functionality of the module.

init.sh
Initializes the root directory.
Upon completion of "terraform init" in the root module,
run this command:   ./.terraform/modules/ec2/examples/init.sh
It will expose the environment variables from the root module into "main.tf" file
and, along with the terraform configuration files, will bring in the following two scripts:

retain_aws_secret.sh
In the state reached by "terraform apply", releases the module that manages AWS SecretsManager service
from the scope of terraform so that the created SecretsManager object would be retained for reuse
unaffected by "terraform destroy" action.
Usage:  ./retain_aws_secret.sh

destroy_aws_secret.sh
Deletes the SecretsManager object previously created by "retain_aws_secret.sh"
from AWS SecretsManager service.

