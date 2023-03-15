#!/bin/bash
FLAVOR="m1.2c4m"
KEYPAIR="javicacheiro"
IMAGE="baseos-Rocky-8.5-v2"
NETWORK="provnet-formacion-vlan-133"

PREFIX="curso800"

for n in {1..5}; do
    openstack server create --flavor $FLAVOR --image $IMAGE --key-name $KEYPAIR --security-group SSH --security-group opensearch --network $NETWORK ${PREFIX}-opensearch-$n
done

openstack server create --flavor $FLAVOR --image $IMAGE --key-name $KEYPAIR --security-group SSH --security-group opensearch --network $NETWORK ${PREFIX}-opensearch-dashboards
