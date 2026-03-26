#!/bin/bash 

# Basic SSH configuration - not prod ready 
echo "ubuntu:password" | chpasswd 
rm /etc/ssh/sshd_config.d/*
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config 
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config 
systemctl restart ssh

# Installing required packages for root and ubuntu  
apt update 
apt-get install python3 python3-pip python3-venv pipx -y
pipx install --include-deps ansible
sudo -H -u ubuntu bash -c "pipx install --include-deps ansible"

echo "" >> /root/.bashrc
echo "export PATH=$PATH:/root/.local/bin/" >> /root/.bashrc
echo "" >> /home/ubuntu/.bashrc
echo "export PATH=$PATH:/root/.local/bin/" >> /home/ubuntu/.bashrc

# Configuring SSH to kubernetes nodes 
