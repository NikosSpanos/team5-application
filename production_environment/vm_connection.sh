#!/bin/bash

set -v
set -x

chmod 600 ./private-key-connector

file_key="./private-key-connector"
file_ip="./public-ip-value"

ipaddress=$(cat $file_ip)

ssh -i $file_key codehubTeam5@$ipaddress
