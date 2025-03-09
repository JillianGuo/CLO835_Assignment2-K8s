# CLO835_Assignment2-K8s

## Pre-requisites

Create docker images for application and (MySQL) database and publish the images in Amazon ECR. 

- Use code and action completed for Assignment 1 (https://github.com/JillianGuo/CLO835_Assignment1_container.git).


## Deploy and configure the required EC2 instance to run K8s cluster

### Deploy the EC2 instance

- Run Terraform code in `EC2/deployment/`

  ```
  ssh-keygen -t rsa -f assignment2-dev
  terraform init
  terraform apply --auto-approve
  ```

### Install necessary tools

- Run Ansible playbook in `EC2/installation/`

  `ansible-playbook -i aws_ec2.yaml playbook.yaml --private-key /path/to/private_key`