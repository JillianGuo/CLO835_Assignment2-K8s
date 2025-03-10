# CLO835_Assignment2-K8s

## Pre-requisites

Create docker images for application and (MySQL) database and publish the images in Amazon ECR. 

- Use code and action completed for Assignment 1 (https://github.com/JillianGuo/CLO835_Assignment1_container.git).


## Deploy and configure the required EC2 instance to run K8s cluster

### Deploy the EC2 instance

- Run (manually) GitHub Actions workflow `Deploy EC2 instance` in repo for this assignment2


### Configure the EC2 instance

- Run Ansible playbook in `EC2/installation/` to install `Docker`, `kubectl`, and `kind`.

  ```
  ansible-playbook -i aws_ec2.yaml playbook.yaml --private-key /path/to/private_key
  ```
  
  > **_NOTE:_**  Same files and method works on Cloud9, but not on GitHub Actions so far. Have to prevents SSH from prompting to confirm the authenticity of the host when connecting for the first time. 
  
- (Optional) Start and enable docker if not yet
  ```
  sudo systemctl start docker
  sudo systemctl enable docker
  ```

- Attach IAM role `LabRole` to the EC2 instance to grant permissions to access ECR
  - Go to the EC2 Console, select the EC2 instance, then click Actions > Security > Modify IAM Role.

- (Optional) Copy files in the `K8s` folder to the EC2 instance
  ```
  scp  -i ../EC2/installation/assignment2-dev * ec2-user@<ec2-public-ip>:~/
  ```


## Deploy K8s cluster (single-node) with `kind`, in the EC2 instance

### Initializing: create kubernetes cluster, namespaces, and ecr-secrets
  ```
  chmod +x init.sh
  ./init.sh
  ```

- (Optional) Verify
  ```
  kubectl get nodes --all-namespaces
  kubectl get ns
  kubectl get secrets --all-namespaces
  ```


### Create database pod using the db-pod Pod manifest

- namespace: `clo835-db`

- Create db pod
  ```
  kubectl apply -f db-pod.yaml
  ```

- Verify the pod has been created in the namespace
  ```
  kubectl get pods -n clo835-db
  ```

- Get IP address of mysql-db-pod
  ```
  kubectl get pod db-pod -n clo835-db -o wide
  ```

- Replace the IP address (DBHOST) in `webapp-pod.yaml` and `webapp-replicaset.yaml` to connect to db


### Create webapp pod using the webapp-pod Pod manifest

- namespace: `clo835-app`

- Create webapp pod
  ```
  kubectl apply -f webapp-pod.yaml
  ```

- Verify the pod has been created in the namespace
  ```
  kubectl get pods -n clo835-app
  ```


### Expose services database and web server (manually, using commands)

- Expose MySQL using Service of type ClusterIP
  
  ```
  kubectl expose pod db-pod -n clo835-db --port=3306
  ```

- Expose web application using Service of type Nodeport

  ```
  kubectl expose pod webapp-pod -n clo835-app --port=8080 --type=NodePort
  ```

- Verify
  
  ```
  kubectl get services --all-namespaces
  ```


### Verify connecting to web server using `curl` in another pod of the cluster

- In `db-pod`

  ```
  kubectl exec -it db-pod -n clo835-db -- sh
  curl http://<cluster-ip>:8080
  ```

- In EC2, check logs of `webapp-pod`

  ```
  kubectl logs webapp-pod -n clo835-app
  ```


### Create web app replicaset using webapp-rs ReplicaSet manifest

- namespace: `default`

- Create webapp replicaset
  ```
  kubectl apply -f webapp-rs.yaml
  ```

- Verify the replicaset and its pods
  ```
  kubectl get rs
  kubectl get pods
  ```


### Create database replicaset using db-rs ReplicaSet manifest

- namespace: `default`

- Create webapp replicaset
  ```
  kubectl apply -f db-rs.yaml
  ```

- Verify the replicaset and its pods
  ```
  kubectl get rs
  kubectl get pods
  ```


### Create deployments of MySQL using deployment manifests (with service manifest) 

- namespace: `default`

- Use the labels from the step of creating db-rs as selectors in the deployment manifest.
  ```
  kubectl apply -f db-deployment.yaml
  ```

- Verify the deployment and the service 
  ```
  kubectl get deployment
  kubectl get rs
  kubectl get svc
  kubectl get pods
  ```

### Create deployments of web app using deployment manifests

- namespace: `default`

- Use the labels from the step of creating db-rs as selectors in the deployment manifest.
  ```
  kubectl apply -f webapp-deployment.yaml
  ```

- Verify the deployment
  ```
  kubectl get deployment
  kubectl get rs
  kubectl get pods
  ```


### Expose web application on NodePort 30000 using service manifest 

- Expose web application service
  ```
  kubectl apply -f webapp-service.yaml
  ```

- Demonstrate accessing the application from EC2 instance using `curl`.
  ```
  curl http://<cluster-ip>:8080
  ```

- Demonstrate accessing the application from the browser.
  - Add inbound rule in security group to allow tcp access at port 30000 from anywhere.
  - Open a browser tab
    ```
    http://<server-ip>:30000
    ```

 > **_NOTE:_**  Expose the NodePort to Your EC2 Host (Update kind.yaml with NodePort mapping)


## Cleanup

  ```
  kubectl delete pods -n <namespace>
  kubectl delete svc -n <namespace>
  kubectl delete rs -n <namespace>
  kubectl delete deployment -n <namespace>
  kubectl delete ns -n <namespace>
  
  kind delete cluster
  ```

## Challenges

### 1. Docker container (kind cluster here) does not inherit AWS credentials from the EC2 instance. Even EC2 has permissions to pull images from ECR, K8s clusters running on this instance don't have.

### 2. Debugging containerized apps in a pod is not straitforward. 

### 3. Kind cluster is running inside Docker, but port 30000 is not mapped to the EC2 host.