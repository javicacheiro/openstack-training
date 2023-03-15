#!/usr/bin/env python3
"""
Export opensearch cluster information for ansible
"""

import openstack

PATTERN = 'curso800'
NETWORK = 'provnet-formacion-vlan-133'

conn = openstack.connect(cloud='cesga')

print('# Inventory aliases')
for n in range(1, 6):
    server = conn.compute.find_server(f'{PATTERN}-opensearch-{n}')
    if server:
        # We have to use the get method to obtain the full server information
        server = conn.compute.get_server(server.id)
        address = server['addresses'][NETWORK][0]['addr']
        print(f'os{n} ansible_host={address}')

print()

# Dashboard
server = conn.compute.find_server(f'{PATTERN}-opensearch-dashboards')
server = conn.compute.get_server(server.id)
address = server['addresses'][NETWORK][0]['addr']
print(f'dashboards1 ansible_host={address}')

print("""
#
# Opensearch hosts
#
# List three nodes elegible for cluster managers (they will also act as data nodes)
[control]
os1
os2
os3
# Additional data nodes
[data]
os4
os5

[opensearch:children]
control
data

# Opensearch Dashboards hosts
[dashboards]
dashboards1""")
