#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "${GREEN}[✓] $1${NC}"
}

print_error() {
    echo -e "${RED}[✗] $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}[!] $1${NC}"
}

# Set AWS Profile and Region
export AWS_PROFILE=585768174978_AdministratorAccess
export AWS_DEFAULT_REGION=us-west-2

# Create VPC
print_status "Creating VPC..."
VPC_ID=$(aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=email-list-api-vpc}]' \
    --query 'Vpc.VpcId' \
    --output text)

# Enable DNS hostnames and DNS support
aws ec2 modify-vpc-attribute \
    --vpc-id $VPC_ID \
    --enable-dns-hostnames

aws ec2 modify-vpc-attribute \
    --vpc-id $VPC_ID \
    --enable-dns-support

# Create public subnet
print_status "Creating public subnet..."
SUBNET_ID=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.1.0/24 \
    --availability-zone us-west-2a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=email-list-api-subnet}]' \
    --query 'Subnet.SubnetId' \
    --output text)

# Create internet gateway
print_status "Creating internet gateway..."
IGW_ID=$(aws ec2 create-internet-gateway \
    --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=email-list-api-igw}]' \
    --query 'InternetGateway.InternetGatewayId' \
    --output text)

# Attach internet gateway to VPC
aws ec2 attach-internet-gateway \
    --internet-gateway-id $IGW_ID \
    --vpc-id $VPC_ID

# Create route table
print_status "Creating route table..."
RT_ID=$(aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=email-list-api-rt}]' \
    --query 'RouteTable.RouteTableId' \
    --output text)

# Add route to internet gateway
aws ec2 create-route \
    --route-table-id $RT_ID \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id $IGW_ID

# Associate route table with subnet
aws ec2 associate-route-table \
    --route-table-id $RT_ID \
    --subnet-id $SUBNET_ID

# Create security group
print_status "Creating security group..."
SG_ID=$(aws ec2 create-security-group \
    --group-name email-list-api-sg \
    --description "Security group for email list API" \
    --vpc-id $VPC_ID \
    --query 'GroupId' \
    --output text)

# Allow inbound SSH, HTTP, and API traffic
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 8000 \
    --cidr 0.0.0.0/0

# Create EC2 instance
print_status "Creating EC2 instance..."
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id ami-0c7217cdde317cfec \
    --instance-type t2.micro \
    --subnet-id $SUBNET_ID \
    --security-group-ids $SG_ID \
    --key-name email-list-api-key \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=email-list-api}]' \
    --user-data file://scripts/ec2-setup.sh \
    --query 'Instances[0].InstanceId' \
    --output text)

# Wait for instance to be running
print_status "Waiting for instance to be running..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

# Get instance public IP
INSTANCE_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

print_status "EC2 instance created successfully!"
print_status "Public IP: $INSTANCE_IP"
print_status "SSH command: ssh -i email-list-api-key.pem ubuntu@$INSTANCE_IP"
print_status "Please wait a few minutes for the instance to complete its setup..."
print_status "Once setup is complete, you can access the API at: http://$INSTANCE_IP:8000" 