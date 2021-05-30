#!/bin/bash

set -v
set -x

file_key="./private-key-connector"
file_ip="./public-ip-value"

privkey = $(cat $file_key)
ipaddress = $(cat $file_ip)

echo $privkey
echo $ipaddress

ssh -i $privkey codehubTeam5@$ipaddress