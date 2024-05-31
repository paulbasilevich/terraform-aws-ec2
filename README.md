# terraform-aws-ec2
Terraform module:
- creates an EC2 instance with access secured to the local host
- deploys Plaid backend on the instance
- deploys Plaid frontend locally.
- sets up the local ssh configuration for straightforward ssh access, namely:
    ssh <key pair name>   (e.g., ssh plaid)
- initially requires Plaid Quickstart credentials set up in the local profile
  (e.g., in ~/.bash_profile file) as follows:
        export PLAID_CLIENT_ID=<Your client ID retrieved from https://dashboard.plaid.com/developers/keys>
        export PLAID_SECRET=<Your "secret" retrieved from the same URI>
 - alonside the deployment and provisioning of the EC2 instance,
   sets up AWS SecretsManager object and commits the credentials to it
 - that object subsequently can replace the local profile as the source of the credentials
   To that end, before running "terraform destroy", run:    ./retain_aws_secret.sh
 - Over time, if the cited SecretsManager object needs to be removed,
   that can be accomplished by running:     ./destroy_aws_secret.sh.
   From that point on, the local profile reinstates as the sought source of the credentials.

Upon completion of Provision instructions,
run the following command to initialize the root directory:
    ./.terraform/modules/ec2/examples/init.sh

After that, running "terraform apply" will deploy Plaid Quickstart service automatically.


    
