# Installing an OpenSearch cluster with Ansible

## Provisioning
We will be need 4 instances.

We can launch the instances using the `provision.sh` script, you just have to edit the KEYPAIR to use:
```
./provision.sh
```

NOTE: The **opensearch security group** is already created enabling access to:
- egress: all
- ingress: tcp 9200 (opensearch), tcp 5601 (opensearch-dashboards)

NOTE: If you adjust the instance names you will have to **update the hostnames** (by default they get the name of the instance) for the scripts to work (alternatively you can update the scripts):
```
hostnamectl set-hostname opensearch-1
```

In future versions of the `openstack-cli` there will be the option to configure the instance hostname:
- [Configurable instance hostnames](https://specs.openstack.org/openstack/nova-specs/specs/xena/implemented/configurable-instance-hostnames.html)

Alternatively you can also launch the instances using **horizon**, it is very simple because we can use **count 3** for the opensearch cluster instances:
- Compute -> Instances: Launch Instance:
  - Instance Name: `opensearch`
  - Count: 3
  - Source: baseos-Rocky-8.5-v2
  - Flavor: **a1.2c4m**: 2 cores, 4GB RAM: this is more than enough for the lab, but you have to edit the `openstack/run_docker-opensearch_version.sh` helper script and reduce the memory. For production we would use something like m1.8c16m
  - Networks: provnet-formacion-vlan-133
  - Security Groups: **opensearch**, SSH
  - Key Pair: your imported key pair

Additionaly we will launch another instance and name it `dashboards`.

## Preparing the configuration
Clone the opensearch ansible playbook repo:
```
git clone https://github.com/opensearch-project/ansible-playbook
```

Add the nodes to the inventory: `inventories/opensearch/hosts`

You can use the `openstacksdk` script provided: `export_ansible_inventory.py` (remember that you will need a `cloud.yaml` file):
```
cp inventories/opensearch/hosts inventories/opensearch/hosts.orig
~/openstacksdk/export_ansible_inventory.py > inventories/opensearch/hosts
```

You can also do it manually.

The final inventory should like like:
```
os1 ansible_host=10.133.28.14   ansible_user=cesgaxuser ansible_become=true ip=10.133.28.14 roles=data,master
os2 ansible_host=10.133.27.161  ansible_user=cesgaxuser ansible_become=true ip=10.133.27.161 roles=data,master
os3 ansible_host=10.133.29.127  ansible_user=cesgaxuser ansible_become=true ip=10.133.29.127 roles=data,master

dashboards1 ansible_host=10.133.29.75  ansible_user=cesgaxuser ansible_become=true ip=10.133.29.75

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
dashboards1
```

Some notes about the parameters used:
- `ansible_host` is the IP address of the instance
- `ip` is the IP address that you want OpenSearch and OpenSearch DashBoards to bind to. In our case we will use the same IP as before, in production we would use a dedicated private tenant network. Do not use `0.0.0.0` because there is a bug and it will not work.
- `ansible_become=true` is to instruct ansible to use sudo from the cesgaxuser account to become root. 

We will now tune the opensearch configuration to set the Java max memory heap to 1GB (it is more than enough for our tests). For that we have to edit `inventories/opensearch/group_vars/all/all.yml`:
```
# Java memory heap values(GB) for opensearch
# You can change it based on server specs
xms_value: 1
xmx_value: 1
```

Additionaly we will disable security since we just want to test the installation, for that we will edit the `opensearch.yml` template at `roles/linux/opensearch/templates/opensearch-multi-node.yml` and we will add the following line at the end of the file:
```
plugins.security.disabled: true
```

We will also do dome changes in `roles/linux/opensearch/tasks/main.yml`:
Comment out the following lines:
```
#- name: include security plugin for opensearch
#  include: security.yml
```

Replace https with http wiht http in the curl commands to test connectivity:
```
- name: Check the opensearch status
  command: curl https://{{ inventory_hostname }}:9200/_cluster/health?pretty -u 'admin:{{ admin_password }}'
  register: os_status

- name: Verify the roles of opensearch cluster nodes
  command: curl http://{{ inventory_hostname }}:9200/_cat/nodes?v -u 'admin:{{ admin_password }}'
  register: os_roles
  run_once: true
```


## Applying the configuration
Let's first check that all nodes are responding and that we are able to connect to them:
```
ansible all -i inventories/opensearch/hosts -m ping
```

Before running the playbook we will need **Java 8** installed in the host were we will run ansible so it can generate the TLS certificates:
```
sudo dnf -y install java-1.8.0-openjdk
```

Now we can run the ansible playbook:
```
ansible-playbook -i inventories/opensearch/hosts opensearch.yml --extra-vars "admin_password=admin kibanaserver_password=secret"
```
with the `extra-vars` option we set the passwords for the users that will be created by the playbook: `admin` for opensearch and `kibanaserver` for opensearch dashboards.

We can test that opensearch is working with:
```
curl http://opensearch-1:9200 -u 'admin:admin'
```

NOTE: If we want to run commands in the nodes of the cluster we can use the `ansible` command, eg. we can restart the opensearch service:
```
ansible -i inventories/opensearch/hosts os-cluster -a 'systemctl restart opensearch'
```

## Cleanup
- Delete the instances
```
openstack server delete opensearch-1 opensearch-2 opensearch-3 opensearch-dashboards
```
