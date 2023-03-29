# Ansible
Ansible is a very popular tool for configuration management.

It is very straightforward to use because the only thing we need to manage the hosts is SSH access. There is no need to install anything in managed hosts.

## Installation
Lab:
- [Installing ansible](labs/ansible_installation.md)

## Ansible Galaxy
You can find a lot of pre-packaged roles and collections in [Ansible Galaxy](https://galaxy.ansible.com/).

## Inventory
The inventory it is where we store the information about the available hosts.

The system wide inventory is in `/etc/ansible/hosts` but we can use also use our own inventory file. We can and set it with the `ANSIBLE_INVENTORY` variable:
```
export ANSIBLE_INVENTORY=~/ansible_hosts
```
or we can pass it as a command-line option:
```
-i ~/ansible_hosts
```

Another useful option it is to include an `ansible.cfg` file in the project's main directory and define there the inventory, as well as any other options we would like to customize for the given project. For example:
```
[defaults]
inventory = inventories/cluster1/hosts
remote_user = cesgaxuser
host_key_checking = false
deprecation_warning = false

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
```


## Playbook
The configuration to apply is defined in a file called a **playbook** and it is composed of plays and each **play** applies **tasks** or **roles** to a given group of **hosts**.

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

All these files are written in YAML so it is good to understand the syntax:
- [YAML Syntax Reference](https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html)

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

## ansible-doc
We can also check the documentation of any module or plugin using the `ansible-doc` CLI:
```
# List all modules
ansible-doc -t module -l

# Get help about the blockinfile module
ansible-doc -t module blockinfile

# Or since module is the defaul type we could just use
ansible-doc -l
ansible-doc blockinfile

# Get a list of all lookup plugins
ansible-doc -t lookup -l

# Get help of the csvfile lookup plugin
ansible-doc -t lookup csvfile
```

# Most useful modules
These are some examples or the most useful modules:

- package: to make sure certain packages are installed
```
- name: Useful packages
  package:
    name:
      - bash-completion
      - vim-enhanced
    state: present
```

- copy: to make sure a given file is present and with the expected content
```
- name: opensearch repo is added
  copy:
    src: opensearch-2.x.repo
    dest: /etc/yum.repos.d/opensearch-2.x.repo
```

- template: to make sure a given file is present and with the expected content (generated from a template)
```
- name: opensearch.yml config file
  template:
    src: opensearch.yml.j2
    dest: /etc/opensearch/opensearch.yml
    owner: opensearch
    group: opensearch
    mode: u=rw,g=r,o=r
  notify: restart opensearch
```

- systemd or service: to make sure a service is running
```
- name: Make sure opensearch is running and enabled
  systemd:
    name: opensearch
    state: started
    enabled: yes
    daemon_reload: true
```

- command: to run a given command
```
- name: security plugin removed
  command: "/usr/share/opensearch-dashboards/bin/opensearch-dashboards-plugin remove securityDashboards"
  become: yes
  become_user: opensearch-dashboards
  args:
    removes: /usr/share/opensearch-dashboards/plugins/securityDashboards/
  notify: restart opensearch-dashboards
```

## References
To create our tasks it is especially useful to have at hand the documentation of the modules and plugins contained in ansible-core:
- [Builtin modules reference](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html)

Other useful references:
- [Ansible cheat-sheet](https://github.com/cherkavi/cheat-sheet/blob/master/ansible.md)
- [Using Ansible playbooks](https://docs.ansible.com/ansible/latest/playbook_guide/index.html)
- [Playbook Keywords](https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html)
- [Index of all modules and plugins](https://docs.ansible.com/ansible/latest/collections/all_plugins.html#all-modules-and-plugins)


## Lab
- [Project Lab: Deploying Opensearch in cluster mode with ansible](../../project-lab/opensearch/cluster-mode-ansible/installing_opensearch_cluster-mode_ansible.md)
