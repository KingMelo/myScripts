#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Update system packages
echo "Updating system packages..."
sudo dnf update -y

# Install Python
echo "Installing Python..."
sudo dnf install -y python3 python3-pip

# Install Node.js
echo "Installing Node.js..."
sudo dnf install -y nodejs

# Install the latest version of Django (using pip)
echo "Installing Django..."
pip3 install --upgrade pip
pip3 install django

# Install Git
echo "Installing Git..."
sudo dnf install -y git

# Install Docker
echo "Installing Docker..."
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io

# Start and enable Docker service
echo "Starting and enabling Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

# Verify installations
echo "Verifying installations..."
python3 --version
echo "Python version: $(python3 --version)"
node --version
echo "Node.js version: $(node --version)"
echo "Django version: $(python3 -m django --version)"
echo "Git version: $(git --version)"
docker --version
echo "Docker version: $(docker --version)"

# Post-install message
echo "Development tools installation completed successfully!"

# Docker post-install steps reminder
echo "To use Docker as a non-root user, add your user to the docker group:"
echo "sudo usermod -aG docker \$USER"
echo "Log out and log back in for the changes to take effect."
