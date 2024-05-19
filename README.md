# Terraform-project1

Terraform to Create EC2 and RDS Instances Inside a Custom VPC on AWS

Commands to run the file 

Run terraform init
Run terraform validate
Run terraform plan -var-file="secrets.tfvars"  and review
Run terraform apply -var-file="secrets.tfvars"
Run terraform destroy -var-file="secrets.tfvars"

Description of Files in Terraform Project:

    main.tf:
        This file contains the main Terraform configuration, including the definition of resources like VPC, subnets, internet gateway, route tables, security groups, RDS instance, EC2 instances, etc.
        It also specifies the required provider and version information. 

    output.tf:
        This file defines the outputs that will be displayed after Terraform applies the configuration.
        Outputs include information such as the public IP address and DNS of the web server, and the endpoint and port of the database.

    secrets.tfvars:
        This file contains sensitive data such as the database username, password, and elastic IP address.
        It is used to provide values for variables that are sensitive or confidential.

    variable.tf:
        This file declares the variables used in the Terraform configuration.
        It includes variables for the AWS region, VPC CIDR block, subnet counts, settings (such as database and web app configurations), public and private subnet CIDR blocks, and sensitive information like the elastic IP, database username, and password.
