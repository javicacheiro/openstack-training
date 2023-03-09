# Terraform
Terraform is a multi-cloud infrastructure provisioning tool.

It uses a declarative language to define the infrastructure that will be provisioned.

In this lab we will see how we can use it as an alternative to `openstack-cli`.

## Installing terraform
```bash
VERSION="1.3.9"
curl -O https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_linux_amd64.zip
sudo dnf -y install unzip
unzip terraform_${VERSION}_linux_amd64.zip
sudo cp terraform /usr/local/bin
```

## Using terraform
The infrastructure to be provisioned is defined in a file named `main.tf`.

In the labs directory you will find a ready-to-use `main.tf` for openstack, you just have to update the credentials.

Download required providers

    terraform init

Format the configuration

    terraform fmt

Validate the configuration

    terraform validate

See the plan about what is going to be executed

    terraform plan

Create infrastructure

    terraform apply

Inspect state

    terraform show

Destroy infrastructure

    terraform destroy

NOTE: Before running apply you have to load your `openstack-rc` file.

## Evolving the infrastructure
When you perform changes in infraestructure, terraform will transition the infrastructure from one state to the next state.

The process to follow is the following:
- You edit `main.tf`
    ```
    vim main.tf
    ```
- You validate the changes
    ```
    terraform validate
    ```
- You see what is the plan to transition from one state to the next one
    ```
    terraform plan
    ```
- If everything looks fine you apply the changes
    ```
    terraform apply
    ```

## Lab
- [Using terraform_basics](labs/using_terraform_basics)

## References:
- https://learn.hashicorp.com/tutorials/terraform/aws-change?in=terraform/aws-get-started
- https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs
- https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/compute_instance_v2
- https://terraform-infraestructura.readthedocs.io/es/latest/adopenstack/index.html

