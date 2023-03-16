# Storage lab
## Create an instance
Create a new instance:
- Name: `<username>-storage-lab`
- Source: baseos-Rocky-8.5-v2
- Flavor: m1.1c1m
- Networks: provnet-formacion-vlan-133
- Securiry groups: SSH
- Key Pair: your keypair

## Create a data volume
Create a new volume that we will use to store the data of the instance:
- Name: `<username>-storage-lab-data`
- Size: 2GB

## Attach the volume to the instance
Attach the new data volume to the instance. You can do it from the volume options: "Manage Attachments" or from the instance options: "Attach Volume".

## Format and mount the volume
Connect to the instance, format and mount the new volume.

```
sudo mkfs.xfs -L data /dev/vdb
sudo mkdir /data
sudo mount LABEL=data /data
```

## Let's create some files
We will create some files to simulate that we have done some changes both to the system volume and to the data volume:
```
sudo touch /root/step_1_completed
sudo touch /data/step_1_completed
```

## Stop the instance
To do a clean snapshot we will stop the instance.
- Option 1: `sudo shutdown -h now`
- Option 2: "Shut Off instance" in the instance options menu

## Dettach the volume
To do a clean snapshot we will detattach the data volume first (in the volume options: "Manage Attachments").

## Create a snapshot of the data volume
Create a snapshot of the volume:
- Name: `<username>-storage-lab-data-snap-1`

## Create a snapshot of the instance
Under the instance options select "Create Snapshot", this will create a snapshot of the system volume of the instance.
- Name: `<username>-storage-lab-snap-1`

## Verify that both snapshots have been created
Go to `Volumes > Snapshots` and verify that the snapshots have been created.

## Attach the data volume
We will now attach again the data volume to the instance.

Go to `Volumes > Volumes` and again use the "Manage Attachments" under the volume options menu.

## Start the instance
We will now start again the instance. In the instance options press: "Start Instance".

Once it has booted, connect to the instance and mount the data volume:
```
sudo mount LABEL=data /data
```

Once it is running connect to it using SSH and create some additional files:
```
sudo touch /root/step_2_completed
sudo touch /data/step_2_completed
```

## Starting a new instance from the snapshot
### Converting the data volume snapshot into a normal volume
First we will convert the data volume snapshot into a normal volume:
- `Volumes > Snapshots`: in the snapshot options select "Create Volume" (use the default name)

### Starting a new instance from the snapshot
Now we will start a new instance using as boot volume the snapshot we have created.

For that just use the standard launch instance wizard with:
- Name: `<username>-storage-lab-from-snap`
- Source:
  - Select Boot Source: Instance Snapshot
  - Select your system volume snapshot: `<username>-storage-lab-snap-1`
- Flavor: m1.1c1m
- Networks: provnet-formacion-vlan-133
- Securiry groups: SSH
- Key Pair: your keypair

### Attach the data volume create from the snapshot
Once the instance is created, we will attach the data volume using the volume we have created previously from the snap.
- Instance options: "Attach Volume": `<username>-storage-lab-data-snap-1`

Once it has booted, connect to the instance and mount the data volume:
```
sudo mount LABEL=data /data
```

### Verify that we are in fact in the state corresponding to when we created the snapshot
Once it has booted, connect to the instance and you will see that the `step_2_completed` files are not present.
```
sudo ls /root
sudo ls /data
```

## Cleaning up
Finally we will clean up:
- Delete the instances you have created in this lab
- Delete the snapshots
- Delete the volumes
- Delete the image corresponding to the instance snapshot (the image type is snapshot)
