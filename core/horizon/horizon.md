# Horizon
Horizon is a Django-based project aimed at providing a complete OpenStack Dashboard.

## Connecting
You connect to:

    https://cloud.srv.cesga.es

Authenticate using your credentials and set domain to "hpc".

![Auth](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-login.png?raw=true)

## Import Key Pair
This will be the Key Pair that will be used to connect to the virtual machines (aka instances)).

If you already have a RSA SSH Key you can import it:
- `Compute > Key Pairs: Import Public Key`
choose Key Type: SSH Key

![Pubkey](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-pubkey.png?raw=true)

If you do not have an existing SSH Key pair you can create one using:
```bash
ssh-keygen -t rsa -b 4096
```
and the public key will be available under: `.ssh/id_rsa.pub`

TIP: You can copy several keys in the text box and all of them will be added.

NOTE: The key is only loaded on boot. Changes to the key will not affect already running instances.

## Create Security Group
The security group represents a sort of firewall for the instances to the network level.

We will create one to allow SSH connections:
- `Network > Security Groups: Create Security Group`
- Name the new security group "SSH"
- Add a rule to allow SSH traffic.

![secgroup create](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-security-group.png?raw=true)
![secgroup rules](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-security-group.png?raw=true)

## Launch instance
To launch a new virtual instance go to:
- `Compute > Instances: Launch instance`

You will have to fill the following:
- Details: Give it a name, you can also select the number of instances under "Count"
- Source: Choose the source image: baseos-Rocky-8.5-v2
- Flavor: m1.1c2m (1 VCPU, 2GB RAM)
- Security Groups: SSH
- Key Pair: javicacheiro

After the instance is booted you will see its "IP Address" and you will be able to connect using SSH using the `cesgaxuser` and your ssh key.

![launch source](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-launch-source.png?raw=true)
![launch security group](https://github.com/javicacheiro/openstack-training/blob/main/img/openstack-launch-security-group.png?raw=true)

## Advanced
### Storage
Under `Volumes` you can create dedicated volumes (block devices) to attach to your instances.
It is also possible to create snapshots and backups of existing volumes.

Later on you can convert a snapshot in a volume and boot a new instance from there, or even you can boot directly from the snapshot.

### Networks (VPC)
You can create your own networks in `Network > Networks`.

This allows you to create your own Virtual Private Cloud (VPC).

Additional networks ports can be attached to a running instance.

## Labs
- [Launching instances with Horizon](labs/launching_instances_with_horizon)
