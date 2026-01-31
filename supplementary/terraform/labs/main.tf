terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.35.0"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  tenant_name = "course-1-project"
  user_name   = "curso800"
  user_domain_name = "Default"
  password    = "xxxx"
  auth_url    = "https://cloud.srv.cesga.es:5000/v3"
  region      = "RegionOne"
}

resource "openstack_compute_keypair_v2" "javier-keypair" {
  name       = "javier-keypair-tf"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCnkmLq6C1ph3H7vHl0FtL0mAQViKJ29v6R/VKcOLOM3wPfU0rjb0pp0rtMIDSsskqJKwRN74gAgakdmXHHW7xg1Cbpnfhl2G3NdrdmQSEmULTfKqInG8i9+Djbfc094ZC/zAg8dt9qxg+uTyGyIL7JIY4zUo1Dwvr6LEqXG6gNjgTP7I0tM02Bd5RxvEyq6izsc4vab7uASmtMAXdzoZvnBxsFU45s4m6yEJyswJ46Z3Kop/31++HiFRxQ97m7BKU9Ya6HX/lMmDTHQPQbNMeVjFUK+L7nHv0qbxykyjKWp2JgLUTzNtDokLfZ7okcpCgaxHcEU2dqATfk92auqvvwykA7GfLb24I34XsVwJCqmo9uiM7mBZQlkiQWG7oUyAEd69slbI4lIkVWRmBltn1r4bHF8zkK8q9pspnMLfWBKGX3cecIu6V22Mqlt+L51Th/RW1FDqyifE5jZ+q9iuJhnSnOk2pQjBQoRIy3g3j0SH7LjM1r2i43NsEXlPA7qCXo/hd6ZNgMpp44QkP/LCgk4uT4SpZxr8PDgCFwNiuxeGvc+MEQApLlcvpl+/+DTeHcZcCR14ePz+JC/r3/hXiDX1nmBfT9or7Gzita9qz4SHv1VCNHsGt9PuWsIRYTG/2u6GywnLn1QXM9XyHG9f1Ru1RsBzPEBAZWcCgPtnpF8Q== jlopez@pcsistemas1"
}

resource "openstack_compute_secgroup_v2" "ssh-and-icmp" {
  name        = "ssh-icmp"
  description = "SSH and ICMP allowed"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }
}

# Create a server
resource "openstack_compute_instance_v2" "test-server-curso800-terraform" {
  name            = "test-server-curso800-terraform"
  image_id        = "61450471-1d15-48ca-af2a-8476cd54b7d8"
  flavor_name     = "m1.1c2m"
  key_pair        = "javier-keypair-tf"
  security_groups = ["default", "ssh-icmp"]

  network {
    name = "provnet-formacion-vlan-133"
  }
}
