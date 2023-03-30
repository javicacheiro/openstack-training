# Installing an OpenSearch cluster with Ansible

## Preparation
You have to download the ansible playbook and the associated files that is in the git repository of the course:
```
git clone https://github.com/javicacheiro/openstack-training.git
cd openstack-training/project-lab/opensearch/cluster-mode-ansible/
```

Edit the following files:
- provision.sh: Update the PREFIX and the KEYPAIR variales
- destroy.sh: Update the PREFIX variable
- export_ansible_inventory.py: Update the PATTERN variable

## Provisioning
We can launch the instances using the `provision.sh` script.

```
./provision.sh
```

Check that the nodes are up and running:
```
openstack server list
```

NOTE: The **opensearch security group** is already created enabling access to:
- egress: all
- ingress: tcp 9200 (opensearch), tcp 9300 (opensearch inter-node), tcp 5601 (opensearch-dashboards)

## Configuring the ansible inventory
Go to the ansible-playbook directory:
```
cd ansible-playbook
```

We have to edit the inventory in `inventories/opensearch/hosts` and add our nodes.

You can use the `openstacksdk` script provided: `export_ansible_inventory.py` (remember that you will need a **clouds config file** in `~/.config/openstack/clouds.yaml`):
```
../export_ansible_inventory.py
```

If everything looks fine you can just write the info to the inventory:
```
../export_ansible_inventory.py > inventories/cluster1/hosts
```

NOTE: You can also populate the inventory manually.

Some notes about the parameters used in the inventory:
- `ansible_host`: in this case it must contain the IP address of the instance (not its hostname)
- `control`: is a group for the opensearch nodes that can act as cluster managers (ie. masters). They will also act as data nodes.

## Applying the configuration
Let's first check that all nodes are responding and that we are able to connect to them:
```
ansible all -m ping -o
```

Now we can run the ansible playbook:
```
ansible-playbook site.yml
```

Alternatively we can also configure each of the parts of the cluster separately:
```
ansible-playbook opensearch.yml
ansible-playbook dashboards.yml
```

Notice that you can rerun the playbook any time you want.

## Verify
We can test that opensearch is working with (`<address>` is the ip address of one of the opensearch nodes):
```
curl -X GET -u admin:admin --silent --insecure http://<address>:9200

# List nodes
curl -X GET -u admin:admin --silent --insecure http://<address>:9200/_cat/nodes?v

# List indices
curl -X GET -u admin:admin --silent --insecure http://<address>:9200/_cat/indices?v
```

We can also check that opensearch dashboards is working:
```
curl -L -X GET --silent http://<dashboards-address>:5601
```

And finally we can connect to the Opensearch Dashboards web and import some data:
```
http://<dashboards-address>:5601 
```

## Executing ad-hoc commands
If we want to run commands in the nodes of the cluster we can use the `ansible` command:

We can restart the opensearch service:
```
ansible opensearch -a 'systemctl restart opensearch'
```

We can check which tcp ports are open and listening in each host you can use:
```
ansible all -a 'ss -ltpn'
```

## Cleanup
- Delete the instances
```
../destroy.sh
```
