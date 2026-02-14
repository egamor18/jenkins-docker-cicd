#!/bin/bash
set -e

LOG=/var/log/user-data.log
exec > >(tee -a $LOG) 2>&1

echo "🚀 Updating system..."
apt update -y
apt upgrade -y

echo "📦 Installing base packages..."
apt install -y ca-certificates curl gnupg lsb-release git unzip htop net-tools

# Install Docker
echo "🐳 Installing Docker..."
curl -fsSL https://get.docker.com | sh

systemctl enable docker
systemctl start docker

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Install Docker Compose for ubuntu user
echo "🔧 Installing Docker Compose..."
mkdir -p /home/ubuntu/.docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64 \
  -o /home/ubuntu/.docker/cli-plugins/docker-compose
chmod +x /home/ubuntu/.docker/cli-plugins/docker-compose
chown -R ubuntu:ubuntu /home/ubuntu/.docker

# Install Python runtime
echo "🐍 Installing Python..."
apt install -y python3 python3-pip python3-venv

# Optional SSH hardening (SAFE MODE)
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart ssh

echo "✅ Setup complete"
