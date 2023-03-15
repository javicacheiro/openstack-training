# Installing an OpenSearch cluster with Ansible

## Preparation
You have to download the ansible playbook and the associated files that is in the git repository of the course:
```
git clone https://github.com/javicacheiro/openstack-training.git
cd openstack-training/project-lab/opensearch/cluster-mode-ansible/
```

Edit the following files:
- provide.sh: Update the PREFIX and the KEYPAIR variales
- destroy.sh: Update the PREFIX variable
- export_ansible_inventory.py: Update the PATTERN variable

## Provisioning
We can launch the instances using the `provision.sh` script.

```
./provision.sh
```

NOTE: The **opensearch security group** is already created enabling access to:
- egress: all
- ingress: tcp 9200 (opensearch), tcp 9300 (opensearch inter-node), tcp 5601 (opensearch-dashboards)

## Configuring the ansible inventory
Go to the ansible-playbook directory:
```
cd openstack-training/project-lab/opensearch/cluster-mode-ansible/ansible-playbook/
```

We have to edit the inventory in `inventories/opensearch/hosts` and add our nodes.

You can use the `openstacksdk` script provided: `export_ansible_inventory.py` (remember that you will need a **clouds config file** in `~/.config/openstack/clouds.yaml`):
```
../export_ansible_inventory.py > inventories/cluster1/hosts
```

You can also populate the inventory manually.

Some notes about the parameters used:
- `ansible_host`: in this case it must contain the IP address of the instance (not its hostname)


## Applying the configuration
Let's first check that all nodes are responding and that we are able to connect to them:
```
ansible all -i inventories/opensearch/hosts -m ping
```

Now we can run the ansible playbook:
```
ansible-playbook site.yml
```

Alternatively we could configure each of the parts of the cluster separately:
```
ansible-playbook opensearch.yml
ansible-playbook dashboards.yml
```

We can test that opensearch is working with (`<address>` is the ip address of one of the opensearch nodes):
```
curl -X GET -u admin:admin --silent --insecure http://<address>:9200

# List nodes
curl -X GET -u admin:admin --silent --insecure https://<address>:9200/_cat/nodes?v

# List indices
curl -X GET -u admin:admin --silent --insecure https://<address>:9200/_cat/indices?v
```

We can also check that opensearch dashboards is working:
```
curl -L -X GET --silent http://<dashboards-address>:5601
```

And finally we can connect to the Opensearch Dashboards web and import some data:

```
http://<dashboards-address>:5601 
```

## Executing commands
If we want to run commands in the nodes of the cluster we can use the `ansible` command, eg. we can restart the opensearch service:
```
ansible opensearch -a 'systemctl restart opensearch'
```

To check which tcp ports are open and listening in each host you can use:
```
ansible all ss -ltpn
```

## Cleanup
- Delete the instances
```
openstack server delete opensearch-1 opensearch-2 opensearch-3 opensearch-dashboards
```
