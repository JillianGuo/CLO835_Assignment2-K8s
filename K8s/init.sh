#!/bin/bash

# Authenticate Docker with ECR 
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 103848042406.dkr.ecr.us-east-1.amazonaws.com

# Create k8s cluster
echo "Creating a single-node K8s cluster using kind ... "
kind create cluster --config kind.yaml

# Create namespaces
kubectl apply -f namespace.yaml
echo "Created two namesapces: clo835-db and clo835-app."

# Create ecr-secret for docker container (the kind cluster) to pull ECR images
aws ecr get-login-password --region us-east-1 | \
kubectl create secret docker-registry ecr-secret \
--namespace=default \
--docker-server=103848042406.dkr.ecr.us-east-1.amazonaws.com \
--docker-username=AWS \
--docker-password=$(aws ecr get-login-password --region us-east-1)
echo "Created ecr-secret for namespace: default"

aws ecr get-login-password --region us-east-1 | \
kubectl create secret docker-registry ecr-secret \
--namespace=clo835-db \
--docker-server=103848042406.dkr.ecr.us-east-1.amazonaws.com \
--docker-username=AWS \
--docker-password=$(aws ecr get-login-password --region us-east-1)
echo "Created ecr-secret for namespace: clo835-db"

aws ecr get-login-password --region us-east-1 | \
kubectl create secret docker-registry ecr-secret \
--namespace=clo835-app \
--docker-server=103848042406.dkr.ecr.us-east-1.amazonaws.com \
--docker-username=AWS \
--docker-password=$(aws ecr get-login-password --region us-east-1)
echo "Created ecr-secret for namespace: clo835-app"
