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

### Configure the EC2 instance

- Run Ansible playbook in `EC2/installation/` to install `Docker`, `kubectl`, and `kind`.

  `ansible-playbook -i aws_ec2.yaml playbook.yaml --private-key /path/to/private_key`
  
  > **_NOTE:_**  Same files and method works on Cloud9, but not on GitHub Actions so far.
  
- (Optional) Start and enable docker if not yet
  ```
  sudo systemctl start docker
  sudo systemctl enable docker
  ```

- Attach IAM role `LabRole` to the EC2 instance to grant permissions to access ECR
  - Go to the EC2 Console, select the EC2 instance, then click Actions > Security > Modify IAM Role.

- Authenticate Docker with ECR 
  `aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 103848042406.dkr.ecr.us-east-1.amazonaws.com`


## Deploy K8s cluster (single-node) with `kind`

### Create kubernetes cluster
`kind create cluster --config kind.yaml`

### Create a namespace for the application
`kubectl apply -f namespace.yaml`


## Deploy containerized application using `pod`, `replicaset` , `deployment` and `service` manifests

### Create ecr-secret for docker container (the kind cluster) to pull ECR images

```
aws ecr get-login-password --region us-east-1 | \
kubectl create secret docker-registry ecr-secret \
--namespace clo835-assignment2-app \
--docker-server=103848042406.dkr.ecr.us-east-1.amazonaws.com \
--docker-username=AWS \
--docker-password=$(aws ecr get-login-password --region us-east-1)
```

- Verify ecr-secret
  `kubectl get secrets -n clo835-assignment2-app`

### Run database pod

`kubectl apply -f db-pod.yaml`

Verify the pod has been created in the proper namespace
`kubectl get pods -n clo835-assignment2-app`

### Run frontend pod

`kubectl apply -f webapp-pod.yaml`

Verify the pod has been created in the proper namespace
`kubectl get pods -n clo835-assignment2-app`



## Challenges

### 1. Docker container (kind cluster here) does not inherit AWS credentials from the EC2 instance