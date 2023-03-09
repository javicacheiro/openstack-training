#!/usr/bin/env python3
"""
Export openstack instance information in /etc/hosts format
"""

import openstack
conn = openstack.connect(cloud='cesga')

servers = conn.compute.servers(sort_key='hostname', sort_dir='asc')

print('# Openstack inventory')
for server in servers:
    name = server['name']
    for net in server['addresses']:
        for port in server['addresses'][net]:
            address = port['addr']
            print(f"{address} {name} {name}.novalocal")
