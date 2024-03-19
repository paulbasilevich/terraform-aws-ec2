# terraform-aws-ec2

To set up the remote backend leveraging S3 and dynamo_db, run:
        ./backend remote

To switch back to the local backend (local terraform.tfstate file), run:
        ./backend local

To list the pre-set workspaces, run:
        terraform workspace list

To check the current workspace, run:
        terraform workspace show

To select a <target> workspace (target = amzn| ubuntu | default), run
        terraform workspace select <target>

To deploy an EC2 instance with access secured to this host, simply run:
        terraform apply -auto-approve

The current workspace defines the AMI type to be used for the target EC2:
    "amazon linux" or "ubuntu" respecively.
(The default workspace maps to "amazon linux")



