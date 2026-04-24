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

# Set up DNS
sed -i "s/nameserver 127.0.0.53/nameserver 169.254.169.253/g" /etc/resolv.conf
sed -i -E "s/search ([a-z]*-[a-z]*-[1-4]{1}).compute.internal/search \1.compute.internal ${domain}/g" /etc/resolv.conf

# Install AWS utility CLI 
apt-get install -y unzip curl
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Set up SSH keys
apt-get install -y jq
mkdir /root/.ssh
chmod 700 /root/.ssh
aws secretsmanager get-secret-value --secret-id ${secretprivatekeyarn} | jq -r ".SecretString" > /root/.ssh/id_ed25519
aws secretsmanager get-secret-value --secret-id ${secretpubkeyarn} | jq -r ".SecretString" > /root/.ssh/id_ed25519.pub
chmod 600 /root/.ssh/id_ed25519
chmod 644 /root/.ssh/id_ed25519.pub
systemctl restart ssh

# Get ansible files for inventory and config
mkdir /opt/ansible
aws s3 cp s3://ansible-config-bucket-tuminaro/ansible.cfg /opt/ansible
aws s3 cp s3://ansible-config-bucket-tuminaro/inventory-defaults /opt/ansible
chown -R ubuntu:ubuntu /opt/ansible

# Get ansible playbook and template for main control plane init
aws s3 cp s3://ansible-config-bucket-tuminaro/main-cp-install.yaml /opt/ansible
mkdir /opt/ansible/templates
aws s3 cp s3://ansible-config-bucket-tuminaro/kubeadm-init-main.j2 /opt/ansible/templates

# Get ansible playbook and template for other control planes to join cluster
aws s3 cp s3://ansible-config-bucket-tuminaro/second-cp-install.yaml /opt/ansible
aws s3 cp s3://ansible-config-bucket-tuminaro/kubeadm-join-cp.j2 /opt/ansible/templates

# Get ansible playbook and template for worker nodes to join cluster
aws s3 cp s3://ansible-config-bucket-tuminaro/worker-install.yaml /opt/ansible
aws s3 cp s3://ansible-config-bucket-tuminaro/kubeadm-join-wk.j2 /opt/ansible/templates

# Get group vars file
mkdir /opt/ansible/group_vars
aws s3 cp s3://ansible-config-bucket-tuminaro/all.yaml /opt/ansible/group_vars







