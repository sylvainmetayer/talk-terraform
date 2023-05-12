#!/usr/bin/env bash

set -x

terraform init
read -r
terraform plan
read -r
#env | grep AWS
#read -r
time terraform apply
# 45s
read -r

ip=$(terraform output -raw public_ip)
read -r

ssh -oStrictHostKeyChecking=no ec2-user@$ip hostname
# 30s
if [[ "$?" -ne 0 ]]; then
    sleep 5
    ssh -oStrictHostKeyChecking=no ec2-user@$ip hostname
fi
read -r

curl "http://$ip"
read -r

sed 's/Hello/Bonjour/' -i default.html.tpl
read -r

terraform apply
read -r

terraform state list
read -r

terraform state show aws_instance.web
read -r

instanceId=$(terraform state show aws_instance.web | grep id | head -n 1 | xargs | cut -d "=" -f 2 | xargs)
terraform state rm aws_instance.web
read -r

curl "http://$ip"
read -r

terraform import aws_instance.web "$instanceId"
