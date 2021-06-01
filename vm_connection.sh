#!/bin/bash

set -v
set -x

chmod 600 $1/$2-private-key-connector
#TBD=>private_key_secret=$(az keyvault secret show --name "production-secret" --vault-name "dlksf-team5keyvault" --query "value" | tr -d "\042")

file_key="$1/$2-private-key-connector"
file_ip="$1/$2-public-ip-value"

ipaddress=$(cat $file_ip)
echo "You requested to connect to vm instance in ip: $ipaddress"

ssh -i $file_key codehubTeam5@$ipaddress
