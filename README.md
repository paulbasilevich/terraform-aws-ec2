# terraform-aws-ec2

Terraform module:

- Creates an EC2 instance with access secured to the local host;

- Deploys Plaid backend service on the instance;

- Deploys Plaid frontend service locally
  (refer to
  https://www.youtube.com/watch?v=E0GwNBFVGik&list=PLyKH4ZiEQ1bH5wpCt9SiyVfHlV2HecFBq&index=3
  for introduction to Plaid technology);

- Sets up the local ssh configuration for straightforward ssh access, namely:
    ssh <key pair name>   (e.g., ssh plaid)

- Initially requires Plaid Quickstart credentials set up in the local profile
  (e.g., in ~/.bash_profile file) as follows:
        export PLAID_CLIENT_ID=<Your client ID retrieved from https://dashboard.plaid.com/developers/keys>
        export PLAID_SECRET=<Your "secret" retrieved from the same URI>

- Alonside the deployment and provisioning of the EC2 instance,
   sets up AWS SecretsManager object and commits the credentials to it.

- That object subsequently can replace the local profile as the source of the credentials.
   To that end, before running "terraform destroy", run:    ./retain_aws_secret.sh

- Over time, if the cited SecretsManager object needs to be removed,
   that can be accomplished by running:     ./destroy_aws_secret.sh.
   From that point on, the local profile reinstates as the sought source of the credentials.

Upon completion of Provision instructions,
run the following command to initialize the root directory:
    ./.terraform/modules/ec2/scripts/init.sh

After that, running "terraform apply" will deploy Plaid Quickstart service automatically.

Subsequent run of "terraform destroy", aside from destroying all the resources deployed in the cloud,
brings the local environment (including the ssh configuration) back to its original state
as it was before running "terraform apply".



AS OF VERSION 3.0.1, THE MODULE DEPLOYS THE EC2 INSTANCE INTO A VPC IT CREATES TO RUN THE INSTANCE IN.

The deployment process is controlled by "deployment_subnet" environment variable, the default value set to "public".

For deployment_subnet = "public", the process involves the following logical steps:
 
    - Create a VPC with a single subnet open for public access.
 
    - Evaluate CIDR block for the target security group to authorize access to the would-be EC2 instance
      either from the local host or from the CIDR the local host belongs in.
 
    - Create the security group effective within the VPC.
 
    - Configure the public subnet, namely:
        * create the internet gateway
        * create the route table and set up the route from the public subnet to the internet gateway;
        * associate the route table with the public subnet;
 
    - Create an EC2 instance in the public subnet with a public IP address assigned.
    
    - In the local ~/.ssh/config file, append a code block that allows ssh access to the EC2 instance
      by the following command pattern: ssh <host_name> (where host_name defaults to "plaid").
 
    - Using ssh access, install the software required to run Plaid Quickstart backend service
      on the deployed EC2 instance and start the service.
 
    - On the local host, install the software required to run Plaid Quickstart frontend service,
      update the proxy configuration file to direct the traffic to the remote backend service, and
      start the frontend service.


For deployment_subnet = "private", the process performs the following extra steps:
    
    - In the security group, modify all ingress rules to accept traffic from the public subnet.
    
    - Create another subnet in the VPC in question and configure it as a private subnet:
        * in the public subnet, create the NAT gateway;
        * create another route table and set up the route from the private subnet to the NAT gateway;
        * associate the route table with the private subnet.
    
    - In the private subnet, create an EC2 instance with only private IP address assigned.
    
    - Similarly to the pertaining step in the public subnet configuration,
      in the local ~/.ssh/config file, append a code block that allows ssh access to the EC2 instance
      by the following command pattern: ssh <host_name> (where host_name defaults to "plaid").
      Use the private IP address for "HostName" and refer to the code block pertaining to the EC2
      set up in the public subnet as a bastion leveraging "ProxyJump <bastion host name>" statement.
    
    - Using ssh access, install the software required to run Plaid Quickstart backend service
      on the EC2 instance deployed in the private subnet and start the service.
    
    - Set up a load balancer to control traffic between the public network and the Plaid Quickstart
      backend service host running in the private network, namely:
        * create the instance target group for the would-be load balancer;
        * create a load balancer spanning the public and the private subnets of the VPC;
        * within the load balancer, create a listener tuned up to the port exposed by
          the Plaid Quickstart backend service (port 8000)
        * attach the EC2 instance running in the private subnet to the foregoing instance target group
        * take a note of the load balancer's DNS and leverage it in configuring the frontend service
          before starting it
