#!/bin/bash

SERVER_NAME="airflow"
DATA_VOLUME="airflow-data"
IMAGE="baseos-Rocky-8.5-v2"
NETWORK="provnet-formacion-vlan-133"
FLAVOR="m1.1c2m"
KEYPAIR="admin"
SECGROUP="airflow"

echo "Keypair configuration"
if ! openstack keypair show $KEYPAIR &> /dev/null; then
    echo "Registering key pair"
    openstack keypair create --public-key ~/.ssh/id_rsa.pub admin
fi

echo "Security group configuration"
if ! openstack security group show $SECGROUP &> /dev/null; then
    echo "Creating security group"
    openstack security group create $SECGROUP
    # SSH
    openstack security group rule create --protocol tcp --dst-port 22:22 --remote-ip 0.0.0.0/0 $SECGROUP
    # Airflow
    openstack security group rule create --protocol tcp --dst-port 8080:8080 --remote-ip 0.0.0.0/0 $SECGROUP
    # ICMP
    openstack security group rule create --protocol icmp --remote-ip 0.0.0.0/0 $SECGROUP
fi

echo "Creating the server"
VMID=$(openstack server create --wait -f value -c id --boot-from-volume 40 --network $NETWORK --flavor $FLAVOR --image $IMAGE --key-name $KEYPAIR --security-group $SECGROUP $SERVER_NAME)

# Get the IP address of the instance
IP=$(openstack server show $VMID -f json -c addresses | jq ".addresses.\"$NETWORK\"[0]" | sed 's/"//g')

if [[ ! $IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "ERROR: Something failed during VM creation, invalid IP address: $IP"
    exit 1
fi

while ! ssh cesgaxuser@$IP echo OK &> /dev/null; do
    echo "Waiting for server to boot"
    sleep 5
done

echo "Data volume configuration"
if ! openstack volume show $SECGROUP &> /dev/null; then
    openstack volume create --size 100 $DATA_VOLUME
    openstack server add volume $SERVER_NAME $DATA_VOLUME
    ssh cesgaxuser@$IP '
        sudo mkfs.xfs -L $(hostname -s) /dev/vdb
        sudo echo "LABEL=$(hostname -s)       /data   xfs     defaults        0 0" >> /etc/fstab
	sudo mkdir /data
        sudo mount /data
    '
fi

echo "Copying files"
scp docker.repo docker-compose.yaml cesgaxuser@$IP:

echo "Installing docker and updating the server"
ssh cesgaxuser@$IP '
    sudo dnf -y update
    sudo cp docker.repo /etc/yum.repos.d
    sudo dnf install -y --enablerepo docker docker-ce docker-compose-plugin
    sudo systemctl enable docker
    sudo reboot
'

sleep 30

while ! ssh cesgaxuser@$IP echo OK &> /dev/null; do
    echo "Waiting for server to reboot"
    sleep 5
done

echo "Installing airflow"
ssh cesgaxuser@$IP '
    mkdir -p ./dags ./logs ./plugins
    ln -s /data data
    echo -e "AIRFLOW_UID=$(id -u)" > .env
    sudo docker compose up airflow-init
    sudo docker compose up -d
'
