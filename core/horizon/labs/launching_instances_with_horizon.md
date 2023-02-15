# Launching instances with horizon
In this lab you will launch two instances using horizon.

We will make use of the "Count" option of the wizard to launch two identical instances.

This option can be used to launch any number of identical instances and then we can configure them using a distributed shell like `clustershell` or a tool like `ansible`.

Follow these steps:
- Import your **key pair**: name it `<login_name>`
- Create a **security group** for ssh: name it `ssh-<login_name>`
- Launch two instances:
  - Details:
    - Name: `<login_name>-test`
    - Count: 2
  - Source: Choose the source image: baseos-Rocky-8.5-v2
  - Networks: Choose an existing provider network (`provnet`)
  - Flavor: m1.1c2m (1 VCPU, 2GB RAM)
  - Security Groups: select the security group you created
  - Key Pair: select your key pair
- Look at the "IP Address" and connect to each instance

Finally destroy the instances and delete the volumes.
