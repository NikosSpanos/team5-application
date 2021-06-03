#!/bin/bash

file_key_v2=$(terraform output -json | jq -r '.output_private_key.value' > ./mykey)
file_ip_v2=$(terraform output -json | jq -r '.output_public_ip.value')

chmod 600 ./mykey

ssh -i ./mykey codehubTeam5@$file_ip_v2

rm -rf ./mykey
