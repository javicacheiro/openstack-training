# Horizon
Horizon is a Django-based project aimed at providing a complete OpenStack Dashboard.

## Connecting
You connect to:

    https://cloud.srv.cesga.es

Authenticate using your credentials and set domain to "hpc".

## Import Key Pair
This will be the Key Pair that will be used to connect to the virtual machines (aka instances)).

If you already have a RSA SSH Key you can import it:
- `Compute > Key Pairs: Import Public Key`
choose Key Type: SSH Key

If do not have an existing SSH Key pair you can create one using:
```bash
ssh-keygen -t rsa -b 4096
```
and the public key will be available under: `.ssh/id_rsa.pub`

## Create Security Group
The security group represents a sort of firewall rules for the instances.

We will create one to allow SSH connections:
- `Network > Security Groups: Create Security Group`
- Name the new security group "SSH"
- Add a rule to allow SSH traffic.

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

## Looking further
### Images
Under `Compute > Images` you can see the existing images.

By default you only see the list of supported images.

You can see additional images if you include also "community" images which include images that are not LTS, images that are not yet fully tested or old versions of existing images. To do that click in the search box and select "Visibility" and then "Community".

### Networks (VPC)
You can create your own networks in `Network > Networks`.

