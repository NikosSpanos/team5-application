#!/bin/bash

set -v
set -x

# chmod 600 $1/$2-private-key-connector
#TBD=>private_key_secret=$(az keyvault secret show --name "production-secret" --vault-name "dlksf-team5keyvault" --query "value" | tr -d "\042")

file_key="$1/$2-private-key-connector"
file_ip="$1/$2-public-ip-value"

# file_key_v2=$(terraform output output_private_key)
# file_ip_v2=$(terraform output output_public_ip | tr -d "\042")

ipaddress=$(cat $file_ip)
#echo "You requested to connect to vm instance in ip: $file_ip"

ssh -i $file_key codehubTeam5@$ipaddress
