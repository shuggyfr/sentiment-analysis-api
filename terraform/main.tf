provider "aws" {
    region = var.aws_region
}

resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = "sentiment-api-vpc"
    }
}

resource "aws_subnet" "public" {
    count = 2
    vpc_id = aws_vpc.main.id
    cidr_block =  "10.0.${count.index + 1}.0/24"
    availability_zone = 
data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "main"{
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "sentiment-api-igw

    }
}


resource "aws_eks_cluster" "main {
    name = var.cluster_name
    role_arn = aws_iam_role.cluster_role.role_arn 
    version = "1.28"

    vpc_config {
        subnet_ids = concat(aws_subnet.public[*].id,aws_subnet.private[*].id) # combine all public and private subnets to a single list
    }

    depends_on = [aws_iam_role_policy_attachment.cluster_policy] # do not create this resource until the iam policy attachment has been created

    tags = {
        Name = "sentiment-api-cluster"

    }
}

resource "aws_eks_node_group" "main" {
        cluster_name = aws_eks_cluster.main.name
        node_group_name = "sentiment-nodes"
        node_role-arn = aws_iam_role.node_role.arn
        subnet_ids = aws_subnet.private[*].id

        scaling_config{
            desired_size = 3
            max_size = 10
            min_size = 1
        }

        instance_types = ["t3.medium"]

        tags = {
            Name = "sentiment-node-group"
        }
}

