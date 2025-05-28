# User Portal

This repository consists of the code for a sample web application for user management and the Infrastructure as Code (IaC) to host it in AWS.

## Repo Structure
* `app` - Contains application code with the Dockerfile
* `chart` - Contains the Helm chart to deploy the application to the Kubernetes cluster
* `datasets` - Contains a sample data set of users to load into the database
* `schema` - Contains the database schema for the application
* `serverless` - Contains the code for a Lambda function that imports user data from the S3 bucket
* `terraform` - Contains the IaC for provisioning the AWS infrastructure where the application will be hosted

---

# Overview

This project deploys the infrastructure and the User Portal application in two main stages. First, the AWS infrastructure required to host the application is provisioned using Terraform. This includes resources such as VPCs, EKS clusters, RDS databases, and other necessary components. Once the infrastructure is in place, the application deployment is handled separately. Docker is used to build container images of the application, and Helm is used to deploy these containerized applications onto the Kubernetes cluster managed by EKS. This separation allows for clear management of infrastructure and application lifecycle.

---

# Deployment Guide

This guide provides step-by-step instructions to deploy the AWS infrastructure and the User Portal application.

## Prerequisites

Before starting, ensure you have the following installed on your local machine:

1. **Terraform**  
   Install Terraform by following the instructions at:  
   https://learn.hashicorp.com/tutorials/terraform/install-cli

2. **AWS CLI**  
   Install AWS CLI by following the instructions at:  
   https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

3. **Docker Desktop**  
   Install Docker Desktop to build and run Docker containers:  
   https://www.docker.com/products/docker-desktop

4. **kubectl** (for Kubernetes cluster management)  
   Install kubectl by following the instructions at:  
   https://kubernetes.io/docs/tasks/tools/

5. **Helm** (for deploying Helm charts)  
   Install Helm by following the instructions at:  
   https://helm.sh/docs/intro/install/

---

## Infrastructure Deployment

## Step 1: Configure AWS CLI

Configure your AWS CLI with appropriate credentials and default region:

```bash
aws configure
```

Provide your AWS Access Key ID, Secret Access Key, default region (e.g., `us-east-1`), and output format (e.g., `json`).

---

## Step 2: Deploy IAM Resources

IAM resources are required for permissions and roles used by other infrastructure components. This step provisions IAM roles and policies required for other AWS services such as EKS, Lambda, and RDS to function securely with appropriate permissions.

1. Navigate to the global terraform directory:

```bash
cd terraform/global
```

2. Initialize Terraform with backend configuration and reconfigure flag:

```bash
terraform init --backend-config=backend/dev.tfvars --reconfigure
```

3. Review the planned changes:

```bash
terraform plan --var-file=vars/dev.tfvars
```

4. Apply the Terraform configuration to create IAM resources:

```bash
terraform apply --var-file=vars/dev.tfvars
```

## Step 3: Deploy AWS Infrastructure

After IAM resources are created, deploy the rest of the infrastructure including VPC, EKS cluster, RDS, Lambda, S3, etc.

1. Navigate to the regional terraform directory (example: `us-east-1`):

```bash
cd ../us-east-1
```

2. Initialize Terraform with backend configuration and reconfigure flag: 

```bash
terraform init --backend-config=backend/dev.tfvars --reconfigure
```

3. Review the planned changes:

```bash
terraform plan --var-file=vars/dev.tfvars
```

4. Apply the Terraform configuration to create infrastructure resources:

```bash
terraform apply --var-file=vars/dev.tfvars
```

The backend configuration ensures Terraform state is stored remotely and shared securely.

---
## Docker Image Creation

For Docker image creation, refer to the [README file](app/README.md) under the `app` directory and follow the steps for building the Docker image.

## Helm Chart Deployment

The User Portal application is deployed via the Helm chart located in the `chart` directory. For detailed deployment steps, please refer to the [README file](chart/README.md) under the `chart` directory.

---

## Important Notes for EKS and WAF Configuration

- **EKS Public Access CIDR:**  
  To troubleshoot and validate `kubectl` commands from your local CLI, ensure that the **public IP address of the person performing the deployment** is added to the EKS cluster's **public access CIDR blocks**. This allows your local machine to communicate with the EKS API server securely.

- **WAF IP Set Configuration:**  
  The AWS WAF is configured to protect the application UI by restricting access based on IP addresses. To avoid being blocked when accessing the application UI from your browser, make sure to **update the WAF IP set with your public IP address**. Failure to do so will result in your requests being blocked by the WAF.

These steps are crucial for successful deployment validation and application access during development and troubleshooting.

---

## Upload Sample Data to S3 and Trigger Lambda

Once the above steps are completed, all infrastructure resources will be deployed. Upload the `test.csv` file located in the `datasets` directory of this repository to the secure S3 bucket. This upload will automatically invoke the Lambda function which pushes the data to the RDS database. This is a manual activity.

Instructions:

- Using AWS Console:  
  1. Open the S3 service in the AWS Management Console.  
  2. Navigate to the configured S3 bucket for the User Portal.  
  3. Click "Upload" and select the `test.csv` file from the `datasets` directory of this repository.  
  4. Complete the upload. The Lambda function will be triggered automatically.

- Using AWS CLI:  
  Run the following command, replacing `<bucket-name>` with your S3 bucket name:

  ```bash
  aws s3 cp datasets/test.csv s3://<bucket-name>/
  ```

## Architecture Overview

The User Portal application is hosted on AWS using a combination of managed services and infrastructure provisioned via Terraform. The architecture includes the following key components:

- **terraform/modules/vpc**: Creates the Virtual Private Cloud (VPC) with public and private subnets, route tables, NAT gateways, and VPC endpoints for S3, providing network isolation and connectivity.
- **terraform/modules/vpc-peering**: Establishes VPC peering connections between VPCs for secure and private communication across network boundaries.
- **terraform/modules/bastion**: Provisions a Bastion EC2 instance with key pairs for secure SSH access to resources within the private network.
- **terraform/modules/alb**: Manages the Application Load Balancer (ALB) resources including listeners, target groups, and security groups.
- **terraform/modules/eks**: Provisions the Elastic Kubernetes Service (EKS) cluster and node groups to host the containerized User Portal application. Node groups use IRSA (IAM Roles for Service Accounts) to securely grant Kubernetes pods permissions to AWS services without using node IAM roles.
- **terraform/modules/rds-aurora**: Sets up the Amazon Aurora RDS cluster and instances for the application database.
- **terraform/modules/lambda**: Deploys Lambda functions with necessary IAM roles and policies for serverless data processing, such as importing user data from S3 to the database.
- **terraform/modules/s3**: Creates S3 buckets for storing datasets and application assets.
- **terraform/modules/iam**: Manages IAM roles and policies, including IRSA to securely grant Kubernetes pods permissions to AWS services.
- **terraform/modules/sg**: Defines security groups to control network access to various resources.
- **terraform/modules/route53_alias_record**: Creates Route 53 DNS alias records pointing to the Application Load Balancer (ALB) for DNS routing.
- **terraform/modules/waf**: Configures AWS WAFv2 Web ACL with custom rules for IP whitelisting, blocking malicious IPs, and protecting against common web attacks. Associates the WAF with the ALB to provide a security layer.

Terraform state is managed remotely via backend configuration to enable collaboration and maintain state consistency across deployments.

---

## Cleanup

**Note:** There is a lifecycle rule to prevent destroy on the NAT IP and termination protection enabled on RDS. Therefore, running `terraform destroy` will fail unless you first disable these protections by setting termination protection to false and removing the lifecycle prevent_destroy rule for the NAT IP.

To clean up and destroy all the resources created by Terraform, run the following commands in each terraform directory:

1. Destroy infrastructure resources:

```bash
cd terraform/us-east-1
terraform destroy --var-file=vars/dev.tfvars
```

2. Destroy IAM resources:

```bash
cd ../global
terraform destroy --var-file=vars/dev.tfvars
```

---
