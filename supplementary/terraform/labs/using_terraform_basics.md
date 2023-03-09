# Using terraform basics
In this lab we will learn the basics of using terraform.

## Installing terraform
First we will install terraform. Terrafrom requires the `openstack-cli` to be installed wo we will do it in our `openstack-cli` server.

Connect to the server:
```
ssh cesgaxuser@openstack-cli
mkdir terraform
cd terraform
```

Download and install terraform (it is just a binary created with go):
```bash
VERSION="1.3.9"
curl -O https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_linux_amd64.zip
sudo dnf -y install unzip
unzip terraform_${VERSION}_linux_amd64.zip
sudo cp terraform /usr/local/bin
```

## Customize the sample main.tf provided
Copy the sample `main.tf` provided to the server:
```
scp main.tf cesgaxuser@openstack-cli:main.tf
```

Connect to the server:
```
ssh cesgaxuser@openstack-cli
mkdir terraform-lab
mv main.tf terraform-lab
```

Edit `main.tf` and perform the following changes:
- Set the username and password of your cloud user:
```
# Configure the OpenStack Provider
provider "openstack" {
  user_name   = "curso800"
  tenant_name = "course-1-project"
  password    = "xxxx"
  auth_url    = "https://cloud.srv.cesga.es:5000/v3"
  region      = "RegionOne"
}
```
- Update the openstack_compute_keypair_v2 resource content
- Update the openstack_compute_instance_v2 resource content

## Deploy the infrastructure
First we will download the required providers

    terraform init

Optionally we can now format the configuration file

    terraform fmt

Now we will validate the configuration

    terraform validate

You should get:
```
Success! The configuration is valid.
```

We can now look at the plan of what is going to happen if we apply the configuration

    terraform plan

You will see something like:
```
Plan: 3 to add, 0 to change, 0 to destroy.
```

So we can now create infrastructure, but first we must load our `openstack-rc` file:

    source ~/course-1-project-openrc.sh

And now we are ready to apply the configuration:

    terraform apply

We can now inspect the final state

    terraform show

We can compare it with what we can see with `openstack-cli`:

    openstack server list
    openstack keypair list
    openstack security group list

And we can check that we can connect to the deployed server:

    ssh cesgaxuser@ip-address

## Evolving the infrastructure
We will now try to evolve the infrastructure performing the following changes:
- We will change the **flavor** of the first server from m1.1c2m to m1.2c2m
- We will add a **second server**

Something like this:
```
resource "openstack_compute_instance_v2" "test-server-curso800-terraform" {
  name            = "test-server-curso800-terraform"
  image_id        = "61450471-1d15-48ca-af2a-8476cd54b7d8"
  flavor_name     = "m1.2c2m"
  key_pair        = "javier-keypair-tf"
  security_groups = ["default", "ssh-icmp"]

  network {
    name = "provnet-formacion-vlan-133"
  }
}

# Create a second server
resource "openstack_compute_instance_v2" "test-server-curso800-terraform-2" {
  name            = "test-server-curso800-terraform-2"
  image_id        = "61450471-1d15-48ca-af2a-8476cd54b7d8"
  flavor_name     = "m1.1c2m"
  key_pair        = "javier-keypair-tf"
  security_groups = ["default", "ssh-icmp"]

  network {
    name = "provnet-formacion-vlan-133"
  }

```

First we will validate the configuration

    terraform validate

And now we can now look at the plan of what is going to happen if we apply the configuration

    terraform plan

You will see the following output:
```
Plan: 1 to add, 1 to change, 0 to destroy.
```

So let's apply the changes:

    terraform apply

We can now inspect the final state

    terraform show

We can compare it with what we can see with `openstack-cli`:

    openstack server list
    openstack keypair list
    openstack security group list

If we had a ssh session open to the initially deployed server we will see that the connection has been closed for the resize operation (openstack reboots the server to do the resize).

But now we should be able to connect to the 2 servers:

    ssh cesgaxuser@ip-address-1
    ssh cesgaxuser@ip-address-2

## Cleanup
Finally we will destroy the infrastructure with:

    terraform destroy
