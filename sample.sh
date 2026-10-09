#!/bin/bash

set -euo pipefail

#######
# Description: Create a VPC in AWS using a shell script
# - create VPC
# - create subnet
# - create internet gateway and route table

# Verify AWS CLI is installed and configured
# if ! command -v aws >/dev/null 2>&1; then
#     echo "AWS CLI is not installed. Please install it and configure your credentials."
#     exit 1
# fi

# if ! aws sts get-caller-identity >/dev/null 2>&1; then
#     echo "AWS CLI is not configured with credentials. Please configure it using 'aws configure'."
#     exit 1
# fi

# Variables
VPC_CIDR="10.0.0.0/16"
SUBNET_CIDR="10.0.1.0/24"
REGION="us-east-1" # Change this to your desired region
VPC_NAME="MyVPC"
SUBNET1_NAME="MySubnet1"
SUBNET_AZ="us-east-1a"

# Create VPC
vpc_id=$(aws ec2 create-vpc --cidr-block "$VPC_CIDR" --query 'Vpc.VpcId' --output text --region "$REGION")
echo "Created VPC with ID: $vpc_id"

# Create subnet
subnet_id=$(aws ec2 create-subnet --vpc-id "$vpc_id" --cidr-block "$SUBNET_CIDR" --availability-zone "$SUBNET_AZ" --query 'Subnet.SubnetId' --output text --region "$REGION")
echo "Created Subnet with ID: $subnet_id in VPC: $vpc_id"

# Tag the VPC and subnet
aws ec2 create-tags --resources "$vpc_id" --tags "Key=Name,Value=${VPC_NAME}" --region "$REGION"
aws ec2 create-tags --resources "$subnet_id" --tags "Key=Name,Value=${SUBNET1_NAME}" --region "$REGION"
echo "Tagged VPC and subnet with names: $VPC_NAME and $SUBNET1_NAME"

# Create an internet gateway
igw_id=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text --region "$REGION")
echo "Created Internet Gateway with ID: $igw_id"

# Attach internet gateway to VPC
aws ec2 attach-internet-gateway --vpc-id "$vpc_id" --internet-gateway-id "$igw_id" --region "$REGION"
echo "Attached Internet Gateway to VPC: $vpc_id"

# Create a route table
route_table_id=$(aws ec2 create-route-table --vpc-id "$vpc_id" --query 'RouteTable.RouteTableId' --output text --region "$REGION")
echo "Created Route Table with ID: $route_table_id"

# Create a route to the internet gateway
aws ec2 create-route --route-table-id "$route_table_id" --destination-cidr-block "0.0.0.0/0" --gateway-id "$igw_id" --region "$REGION"
echo "Created route to Internet Gateway in Route Table: $route_table_id"

# Associate the route table with the subnet
association_id=$(aws ec2 associate-route-table --route-table-id "$route_table_id" --subnet-id "$subnet_id" --query 'AssociationId' --output text --region "$REGION")
echo "Associated Route Table: $route_table_id with Subnet: $subnet_id"

# Keep the resources available for two minutes, then remove only resources
# created by this script.
echo "Resources will be deleted in 2 minutes."
sleep 120

echo "Deleting resources created by this script..."
aws ec2 disassociate-route-table --association-id "$association_id" --region "$REGION"
aws ec2 delete-route-table --route-table-id "$route_table_id" --region "$REGION"
aws ec2 detach-internet-gateway --internet-gateway-id "$igw_id" --vpc-id "$vpc_id" --region "$REGION"
aws ec2 delete-internet-gateway --internet-gateway-id "$igw_id" --region "$REGION"
aws ec2 delete-subnet --subnet-id "$subnet_id" --region "$REGION"
aws ec2 delete-vpc --vpc-id "$vpc_id" --region "$REGION"
echo "Deleted VPC, subnet, internet gateway, and route table."

