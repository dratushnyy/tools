#!/bin/bash

# Check if the AWS CLI is installed
if ! command -v aws &> /dev/null
then
    echo "AWS CLI is not installed. Please install it and configure your credentials before running this script."
    exit 1
fi

# Retrieve the instances
instances=$(aws ec2 describe-instances --query "Reservations[].Instances[].[InstanceId, InstanceType, PublicIpAddress, State.Name, Tags[?Key=='Name'] | [0].Value]" --output text)

# Check if there are any instances
if [ -z "$instances" ]
then
    echo "No EC2 instances found."
    exit 0
fi

# Print the table header
printf "%-15s | %-15s | %-15s | %-15s | %-15s\n" "Instance ID" "Instance Name" "Instance Size" "Public IP" "Instance Status"

# Print the table rows
while IFS=$'\t' read -r instance_id instance_type public_ip status name; do
    printf "%-15s | %-15s | %-15s | %-15s | %-15s\n" "$instance_id" "$name" "$instance_type" "$public_ip" "$status"
done <<< "$instances"

