#!/bin/bash
FLAVOR="a1.2c4m"
KEYPAIR="javicacheiro"
IMAGE="baseos-Rocky-8.5-v2"
NETWORK="provnet-formacion-vlan-133"

for n in {1..3}; do
    openstack server create --flavor $FLAVOR --image $IMAGE --key-name $KEYPAIR --security-group SSH --security-group opensearch --network $NETWORK opensearch-$n
done

openstack server create --flavor $FLAVOR --image $IMAGE --key-name $KEYPAIR --security-group SSH --security-group opensearch --network $NETWORK opensearch-dashboards
