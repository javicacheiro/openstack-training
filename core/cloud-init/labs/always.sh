#!/bin/bash

date >> /root/user-data.log
echo "Cleaning dnf cache" >> /root/user-data.log

dnf clean all
