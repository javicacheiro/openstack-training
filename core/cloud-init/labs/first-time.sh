#!/bin/bash

date >> /root/user-data.log
echo "Updating packages" >> /root/user-data.log

dnf -y update

date >> /root/user-data.log
echo "Ended updating packages" >> /root/user-data.log
