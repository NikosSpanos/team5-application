#!/bin/bash

set -v
set -x

read env_instance

chmod 600 ./production_environment/$env_instane-private-key-connector
private_key_secret=$(az keyvault secret show --name "production-secret" --vault-name "dlksf-team5keyvault" --query "value" | tr -d "\042")

file_key="./production_environment/$env_instance-private-key-connector"
file_ip="./production_environment/$env_instance-public-ip-value"

ipaddress=$(cat $file_ip)

ssh -i $private_key_secret codehubTeam5@$ipaddress
