aws_region = "ap-southeast-2"

environment = "platform-dev"

cluster_name = "platform-dev-eks"

vpc_cidr = "10.64.0.0/16"

kubernetes_version = "1.36"

instance_types = [
  "t4g.small"
]

min_size     = 1
desired_size = 1
max_size     = 3