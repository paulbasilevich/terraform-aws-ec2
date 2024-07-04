# terraform-aws-ec2
Terraform module:
- creates an EC2 instance with access secured to the local host;
- deploys Plaid backend on the instance;
- deploys Plaid frontend locally
  (refer to
  https://www.youtube.com/watch?v=E0GwNBFVGik&list=PLyKH4ZiEQ1bH5wpCt9SiyVfHlV2HecFBq&index=3
  for introduction to Plaid technology);
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
    ./.terraform/modules/ec2/scripts/init.sh

After that, running "terraform apply" will deploy Plaid Quickstart service automatically.

AS OF VERSION 3.0.1, THE MODULE DEPLOYS THE EC2 INSTANCE INTO A VPC IT CREATES TO HOST THE INSTANCE IN.
The deployment process is controlled by "deployment_subnet" environment variable, the default value set to "public".

For deployment_subnet = "public", the process involves the following logical steps:
    - create a VPC with a single subnet open for public access;
    - evaluate CIDR block for the target security group to authorize access to the would-be EC2 instance
      either from the local host or from the CIDR the local host belongs in;
    - create the security group effective within the VPC
    - configure the public subnet, namely:
        * create the internet gateway
        * create the route table and set up the route from the public subnet to the internet gateway
    - create the EC2 instance in the public subnet with a public IP address assigned;
    - in the local ~/.ssh/config file, append a code block that allows ssh access to the EC2 instance
      by the following command pattern: ssh <host_name> (where host_name defaults to "plaid").
    - using ssh access, install the software required to run Plaid Quickstart backend service
      on the deployed EC2 instance and start the service
    - on the local host, install the software required to run Plaid Quickstart frontend service,
      update the proxy configuration file to direct the traffic to the remote backend service, and
      start the frontend service.





    
