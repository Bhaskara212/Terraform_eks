# AWS EKS Cluster with Terraform

This repository contains Terraform configuration to provision an Amazon EKS cluster and its supporting AWS infrastructure.

## Overview

The infrastructure will create:

- AWS VPC
- Public and private subnets
- Internet Gateway
- NAT Gateway
- Route tables
- Security groups
- Amazon EKS cluster
- EKS managed node group
- EKS managed add-ons
- IAM roles and permissions required by EKS
- ARM64 worker nodes

### Architecture

```text
                         AWS Account
                             |
                             v
                     Region: eu-west-2
                             |
                             v
                    +------------------+
                    |       VPC        |
                    |  10.64.0.0/16    |
                    +------------------+
                       /            \
                      /              \
                     v                v
              Public Subnets     Private Subnets
              -------------      ----------------
              eu-west-2a         eu-west-2a
              eu-west-2b         eu-west-2b
              eu-west-2c         eu-west-2c
                   |                   |
                   |              EKS Nodes
                   |                   |
              NAT Gateway              |
                   |                   |
                   +---------+---------+
                             |
                             v
                       EKS Cluster
                             |
              +--------------+--------------+
              |              |              |
           CoreDNS       kube-proxy       VPC CNI
                             |
                             v
                    Managed Node Group
                       m7g.2xlarge
                          ARM64
```

---

## Prerequisites

Make sure the following tools are installed.

### AWS CLI

Check:

```bash
aws --version
```

Expected:

```text
aws-cli/2.x.x
```

### Terraform

Check:

```bash
terraform version
```

Expected:

```text
Terraform v1.16.5
on windows_amd64
```

### kubectl

Check:

```bash
kubectl version --client
```

### AWS Authentication

Verify that your AWS CLI is connected to the correct AWS account:

```bash
aws sts get-caller-identity
```

Example:

```json
{
    "UserId": "AIDAxxxxxxxxxxxxxxxx",
    "Account": "706119787",
    "Arn": "arn:aws:iam::a"
}
```

---

# AWS Configuration

## Configure AWS CLI

If AWS CLI has not been configured:

```bash
aws configure
```

Provide:

```text
AWS Access Key ID:
AWS Secret Access Key:
Default region name:
Default output format: json
```

For the London region:

```text
eu-west-2
```

Verify the configured region:

```bash
aws configure get region
```

Expected:

```text
eu-west-2
```

You can change the region later with:

```bash
aws configure set region eu-west-2
```

---

# Project Structure

Recommended repository structure:

```text
eks-terraform/
│
├── README.md
│
├── versions.tf
├── provider.tf
├── variables.tf
├── terraform.tfvars
│
├── vpc.tf
├── eks.tf
├── outputs.tf
│
└── .gitignore
```

---

# Terraform Configuration

## Terraform Version

This project requires Terraform:

```text
>= 1.11.0
< 2.0.0
```

Terraform provider versions:

```text
AWS provider: ~> 6.0
```

---

# AWS Region

The default region for this deployment is:

```text
eu-west-2
```

This is the AWS London region.

The region can be changed in:

```text
terraform.tfvars
```

Example:

```hcl
aws_region = "eu-west-2"
```

---

# Network Configuration

The EKS cluster uses the following VPC:

```text
VPC CIDR:
10.64.0.0/16
```

Three Availability Zones are used.

## Public Subnets

```text
10.64.0.0/20
10.64.16.0/20
10.64.32.0/20
```

## Private Subnets

```text
10.64.48.0/20
10.64.64.0/20
10.64.80.0/20
```

Private subnets are used for the EKS worker nodes.

Public subnets are used for internet-facing AWS resources when required.

---

# EKS Configuration

The initial cluster configuration is:

| Configuration | Value |
|---|---|
| AWS Region | `ap-southest-2` |
| EKS Version | `1.36` |
| VPC CIDR | `10.64.0.0/16` |
| Availability Zones | 3 |
| Node Architecture | ARM64 |
| Instance Type | `m7g.2xlarge` |
| Minimum Nodes | 1 |
| Desired Nodes | 1 |
| Maximum Nodes | 3 |

---

# EKS Add-ons

The following EKS managed add-ons are enabled:

```text
vpc-cni
coredns
kube-proxy
aws-ebs-csi-driver
```

These provide:

- AWS VPC networking
- Kubernetes DNS
- Kubernetes networking proxy
- EBS persistent volume support

---

# Initialize Terraform

From the repository directory:

```bash
terraform init
```

This downloads the required Terraform providers and modules.

---

# Format Terraform

Run:

```bash
terraform fmt -recursive
```

---

# Validate Configuration

Run:

```bash
terraform validate
```

Expected:

```text
Success! The configuration is valid.
```

---

# Review Terraform Plan

Before creating AWS resources:

```bash
terraform plan
```

Review the resources carefully.

Terraform should show resources such as:

```text
VPC
Subnets
Route Tables
NAT Gateway
Internet Gateway
Security Groups
IAM Roles
EKS Cluster
EKS Node Group
EKS Add-ons
```

---

# Create the Infrastructure

Once the plan has been reviewed:

```bash
terraform apply
```

Terraform will ask for confirmation:

```text
Do you want to perform these actions?
  Enter a value:
```

Enter:

```text
yes
```

---

# Configure kubectl

After the EKS cluster is created, configure kubectl:

```bash
aws eks update-kubeconfig \
  --region eu-west-2 \
  --name <cluster-name>
```

For example:

```bash
aws eks update-kubeconfig \
  --region eu-west-2 \
  --name my-eks-cluster
```

---

# Verify EKS Cluster

Check the cluster:

```bash
aws eks describe-cluster \
  --region eu-west-2 \
  --name <cluster-name>
```

Check Kubernetes nodes:

```bash
kubectl get nodes
```

Expected:

```text
NAME                                      STATUS   ROLES    AGE   VERSION
ip-10-64-xx-xx.eu-west-2.compute.internal Ready    <none>   ...   ...
ip-10-64-xx-xx.eu-west-2.compute.internal Ready    <none>   ...   ...
ip-10-64-xx-xx.eu-west-2.compute.internal Ready    <none>   ...   ...
```

---

# Check Kubernetes System Pods

Run:

```bash
kubectl get pods -A
```

Check EKS system namespace:

```bash
kubectl get pods -n kube-system
```

Expected components include:

```text
coredns
aws-node
kube-proxy
ebs-csi-controller
ebs-csi-node
```

---

# Check EKS Add-ons

Run:

```bash
aws eks list-addons \
  --cluster-name <cluster-name> \
  --region eu-west-2
```

Check a specific add-on:

```bash
aws eks describe-addon \
  --cluster-name <cluster-name> \
  --addon-name vpc-cni \
  --region eu-west-2
```

---

# Useful AWS Commands

## Check AWS identity

```bash
aws sts get-caller-identity
```

## Check current region

```bash
aws configure get region
```

## List VPCs

```bash
aws ec2 describe-vpcs \
  --region eu-west-2
```

## List subnets

```bash
aws ec2 describe-subnets \
  --region eu-west-2
```

## List EKS clusters

```bash
aws eks list-clusters \
  --region eu-west-2
```

---

# Useful Kubernetes Commands

## Nodes

```bash
kubectl get nodes
```

## Pods

```bash
kubectl get pods -A
```

## Services

```bash
kubectl get svc -A
```

## Deployments

```bash
kubectl get deployments -A
```

## Namespaces

```bash
kubectl get namespaces
```

## Node details

```bash
kubectl describe nodes
```

## Pod logs

```bash
kubectl logs <pod-name> -n <namespace>
```

---

# Terraform State

Terraform maintains the infrastructure state in:

```text
terraform.tfstate
```

Do **not** commit this file to Git.

Add the following to `.gitignore`:

```gitignore
# Terraform
.terraform/
*.tfstate
*.tfstate.*
.terraform.lock.hcl

# Crash logs
crash.log
crash.*.log

# Variable files containing sensitive values
*.tfvars
*.tfvars.json

# Override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Terraform plan files
*.tfplan
```

> If `terraform.tfvars` contains only non-sensitive configuration, you may choose to commit it. Do not commit AWS credentials or secrets.

---

# Destroy Infrastructure

When the test environment is no longer required:

```bash
terraform destroy
```

Review the resources carefully before confirming.

Enter:

```text
yes
```

This will delete the infrastructure managed by Terraform.

---

# Important Security Notes

### Never commit AWS credentials

Do not put this in Terraform:

```hcl
provider "aws" {
  access_key = "AKIA..."
  secret_key = "..."
}
```

Use AWS CLI credentials instead:

```bash
aws configure
```

Terraform will automatically use the configured AWS credentials.

### Never commit secrets

Avoid committing:

```text
AWS access keys
AWS secret keys
passwords
tokens
private keys
database credentials
```

---

# Recommended Deployment Flow

Use the following workflow whenever making infrastructure changes:

```text
1. Configure AWS CLI
        |
        v
2. Verify AWS account
        |
        v
3. terraform init
        |
        v
4. terraform fmt
        |
        v
5. terraform validate
        |
        v
6. terraform plan
        |
        v
7. Review changes
        |
        v
8. terraform apply
        |
        v
9. Configure kubectl
        |
        v
10. kubectl get nodes
        |
        v
11. Test workloads
```

---

# Troubleshooting

## AWS credentials not found

Error:

```text
Unable to locate credentials
```

Run:

```bash
aws configure
```

Then:

```bash
aws sts get-caller-identity
```

---

## Wrong AWS region

Check:

```bash
aws configure get region
```

Change it:

```bash
aws configure set region eu-west-2
```

---

## Terraform not found

Check:

```bash
terraform version
```

If Terraform is installed but Git Bash cannot find it, restart Git Bash and check:

```bash
which terraform
```

---

## kubectl cannot connect to cluster

Run:

```bash
aws eks update-kubeconfig \
  --region eu-west-2 \
  --name <cluster-name>
```

Then:

```bash
kubectl get nodes
```

---

# Future Improvements

The initial setup can later be extended with:

- Karpenter
- Cluster Autoscaler
- AWS Load Balancer Controller
- External DNS
- Metrics Server
- Prometheus
- Grafana
- Argo CD
- cert-manager
- AWS Secrets Manager / External Secrets
- EBS CSI
- EFS CSI
- Network policies
- Private EKS endpoint
- VPC Flow Logs
- CloudWatch Container Insights
- Terraform remote state using S3 + DynamoDB/locking
- CI/CD using GitHub Actions
- Terratest for EKS infrastructure testing

---

# Ownership

AWS Account:

```text
706119322787
```

IAM User:

```text
teja
```

Default AWS Region:

```text
ap-southest-2
```

Terraform:

```text
1.16.5
```

Operating System:

```text
Windows
```

Architecture:

```text
windows_amd64
```

---

# Status

Current setup:

```text
AWS CLI              ✅
AWS Authentication   ✅
Terraform            ✅
AWS Account Access   ✅
AWS Region           ap-southest-2
EKS                  ⏳ To be created
VPC                  ⏳ To be created
Worker Nodes         ⏳ To be created
kubectl              ⏳ To be configured
```