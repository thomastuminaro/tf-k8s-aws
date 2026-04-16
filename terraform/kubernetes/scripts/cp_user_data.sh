#!/bin/bash

# Configuring SSH access 
echo "ubuntu:password" | chpasswd 
rm /etc/ssh/sshd_config.d/*
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config 
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config 
systemctl restart ssh

hostnamectl set-hostname $(cp_hostname)

# Set up DNS
sed -i "s/nameserver 127.0.0.53/nameserver 169.254.169.253/g" /etc/resolv.conf
sed -i -E "s/search ([a-z]*-[a-z]*-[1-4]{1}).compute.internal/search \1.compute.internal ${domain}/g" /etc/resolv.conf

# Install AWS utility CLI 
apt-get install -y unzip curl
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Set up SSH keys
mkdir /root/.ssh
chmod 700 /root/.ssh
mkdir /home/ubuntu/.ssh
chmod 700 /home/ubuntu/.ssh
chown -R ubuntu:ubuntu /home/ubuntu
aws secretsmanager get-secret-value --secret-id ${secretpubkeyarn} | jq -r ".SecretString" >> /root/.ssh/authorized_keys 
aws secretsmanager get-secret-value --secret-id ${secretpubkeyarn} | jq -r ".SecretString" >> /home/ubuntu/.ssh/authorized_keys 
chmod 600 /root/.ssh/authorized_keys 
chmod 600 /home/ubuntu/.ssh/authorized_keys
systemctl restart ssh

# All other packages and system settings will be managed through ansible 