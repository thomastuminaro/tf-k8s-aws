#!/bin/bash

# Configuring SSH access 
echo "ubuntu:password" | chpasswd 
rm /etc/ssh/sshd_config.d/*
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config 
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config 
systemctl restart ssh

hostnamectl set-hostname worker

# All other packages and system settings will be managed through ansible 