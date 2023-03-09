#!/usr/bin/env python3
"""
Export opensearch cluster information for ansible
"""

import openstack

NETWORK = 'provnet-formacion-vlan-133'

conn = openstack.connect(cloud='cesga')

for n in range(1, 4):
    server = conn.compute.find_server(f'opensearch-{n}')
    if server:
        # We have to use the get method to obtain the full server information
        server = conn.compute.get_server(server.id)
        address = server['addresses'][NETWORK][0]['addr']
        print(f'os{n} ansible_host={address} ansible_user=cesgaxuser ansible_become=true ip={address} roles=data,master')

print()

# Dashboard
server = conn.compute.find_server(f'opensearch-dashboards')
server = conn.compute.get_server(server.id)
address = server['addresses'][NETWORK][0]['addr']
print(f'dashboards1 ansible_host={address} ansible_user=cesgaxuser ansible_become=true ip={address} roles=data,master')

print("""
# List all the nodes in the os cluster
[os-cluster]
os1
os2
os3

# List all the Master eligible nodes under this group
[master]
os1
os2
os3

[dashboards]
dashboards1""")
