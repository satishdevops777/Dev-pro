#!/bin/bash

##### Change these values ###
ZONE_ID=$(aws route53 list-hosted-zones --query "HostedZones[*].{ID:Id,Name:Name,Private:Config.PrivateZone}" --output text | awk '{print $1}' | awk -F / '{print $3}')
DOMAIN_NAME=$(aws route53 list-hosted-zones --query "HostedZones[*].{ID:Id,Name:Name,Private:Config.PrivateZone}" --output text | awk '{print $2}' | sed -e 's/.$//')
SG_NAME="allow-all"
AWS_REGION="us-east-1"
#ENV="dev"
#############################
sudo rm -f /tmp/record.json

env=dev

create_ec2() {
  PRIVATE_IP=$(aws ec2 run-instances \
      --image-id ${AMI_ID} \
      --instance-type t3.small \
      --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${COMPONENT}}]"  \
      --security-group-ids ${SGID} --region ${AWS_REGION} | jq '.Instances[].PrivateIpAddress' | sed -e 's/"//g')

  sed -e "s/IPADDRESS/${PRIVATE_IP}/" -e "s/COMPONENT/${COMPONENT}/" -e "s/DOMAIN_NAME/${DOMAIN_NAME}/" /tmp/labautomation/aws/route53.json >/tmp/record.json
  aws route53 change-resource-record-sets --hosted-zone-id ${ZONE_ID} --change-batch file:///tmp/record.json | jq
}


## Main Program
AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=Centos-8-DevOps-Practice" --region ${AWS_REGION} | jq '.Images[].ImageId' | sed -e 's/"//g')
if [ -z "${AMI_ID}" ]; then
  echo "AMI_ID not found"
  exit 1
fi

SGID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=${SG_NAME} --region ${AWS_REGION} | jq  '.SecurityGroups[].GroupId' | sed -e 's/"//g')
if [ -z "${SGID}" ]; then
  echo "Given Security Group does not exit"
  exit 1
fi


for component in catalogue-a cart-a user-a shipping-a payment-a frontend-a mongodb-a mysql-a rabbitmq-a redis-a dispatch-a; do
  COMPONENT="${component}"
  create_ec2
done