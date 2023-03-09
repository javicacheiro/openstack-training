# Ansible
Ansible is a very popular tool for configuration management.

It is very straightforward to use because the only thing we need to manage the hosts is SSH access. There is no need to install anything in managed hosts.

## Installation
Lab:
- [Installing ansible](labs/ansible_installation.md)

## Ansible Galaxy
You can find a lot of pre-packaged roles and collections in [Ansible Galaxy](https://galaxy.ansible.com/).

## Inventory
The inventory it is we store the information about the available hosts.

The system wide inventory is in `/etc/ansible/hosts` but we can use also use our own inventory file. We can and set it with the `ANSIBLE_INVENTORY` variable:
```
export ANSIBLE_INVENTORY=~/ansible_hosts
```
or we can pass it as a command-line option:
```
-i ~/ansible_hosts
```

## Playbook
The configuration to apply is defined in a file called a `playbook`.

The following is a sample playbook for opensearch:
```yaml
---

- name: opensearch installation & configuration
  hosts: os-cluster
  gather_facts: true
  roles:
    - { role: linux/opensearch }

- name: opensearch dashboards installation & configuration
  hosts: dashboards
  gather_facts: true
  roles:
    - { role: linux/dashboards }
```
# Facts
Facts represent discovered variables about a system that can be used in playbooks to perform conditional actions.

You can see the facts of a system with:

    ansible all -m setup

## Basic usage
### ansible command
We can use the `ansible` command to run a single task against a set of hosts.

The commands follow this syntax:

    ansible -m MODULE_NAME -a MODULE_ARGS

To ping all hosts defined in the inventory using the ping module:

    ansible all -m ping

To run an arbitrary command in the opensearch group:

    ansible opensearch -m shell -a hostname

Since the `shell` module is the default one, this command can be simplified to:

    ansible opensearch -a hostname

To copy a file to all hosts in the opensearch group:

    ansible opensearch -m copy -a "src=/etc/hosts dest=/tmp/hosts"

### ansible-playbook command
To run a playbook we will use the `ansible-playbook` command, for example:
```
ansible-playbook opensearch.yml
```

We can also indicate an inventory:
```
ansible-playbook -i inventories/opensearch/hosts opensearch.yml
```

And if needed we can also provide certain vars:
```
ansible-playbook -i inventories/opensearch/hosts opensearch.yml --extra-vars "admin_password=admin kibanaserver_password=secret"
```

## Check mode ("dry run") testing mode
Use the option --check:

    ansible-playbook management.yml --extra-vars target=mngt0-1,mngt0-2 --tags=slurm --check

To show the differences use --diff:

    ansible-playbook management.yml --extra-vars target=mngt0-1,mngt0-2 --tags=slurm --check --diff


