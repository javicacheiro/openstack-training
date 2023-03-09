# Ansible installation

## Installation
```
sudo dnf install epel-release
sudo dnf install ansible
```

# Configuration
Update Ansible configuration in `/etc/ansible/ansible.cfg`:
```
[defaults]
host_key_checking=False
pipelining=True
forks=100
```
