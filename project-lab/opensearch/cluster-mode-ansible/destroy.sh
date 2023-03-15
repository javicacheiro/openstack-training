#!/bin/bash
FLAVOR="m1.2c4m"
KEYPAIR="javicacheiro"
IMAGE="baseos-Rocky-8.5-v2"
NETWORK="provnet-formacion-vlan-133"

PREFIX="curso800"

for n in {1..5}; do
    openstack server delete ${PREFIX}-opensearch-$n
done

openstack server delete ${PREFIX}-opensearch-dashboards
