variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "platform-dev"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "platform-dev-eks"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.64.0.0/16"
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.36"
}

variable "instance_types" {
  description = "EKS node instance type"
  type        = list(string)
  default     = ["t4g.small"]
}

variable "min_size" {
  type    = number
  default = 1
}

variable "desired_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 3
}