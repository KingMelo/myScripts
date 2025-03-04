#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Use sudo ./setup.sh"
    exit 1
fi

USERNAME="king"
PACKAGES="sudo curl wget git vim tmux htop build-essential ufw fail2ban"

echo "Updating system..."
apt update && apt upgrade -y

# Ensure the user exists
if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists."
else
    echo "Creating user: $USERNAME"
    adduser --gecos "" --disabled-password "$USERNAME"
    echo "$USERNAME:changeme" | chpasswd  # Set a default password
fi

echo "Adding $USERNAME to sudoers using multiple methods..."

# Method 1: Add user to sudo group (Primary method)
usermod -aG sudo "$USERNAME"

# Method 2: Create a sudoers file for the user (Alternative)
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/$USERNAME
chmod 0440 /etc/sudoers.d/$USERNAME

# Method 3: Directly modify /etc/sudoers (Failsafe method)
if ! grep -q "^$USERNAME " /etc/sudoers; then
    echo "$USERNAME ALL=(ALL) ALL" | EDITOR="tee -a" visudo
fi

# Method 4: If 'sudo' group is missing, try 'wheel' (Older method)
if grep -q "^wheel:" /etc/group; then
    usermod -aG wheel "$USERNAME"
fi

# Verify sudo permissions
echo "Verifying sudo permissions..."
sudo -l -U "$USERNAME"

echo "Installing essential packages..."
apt install -y $PACKAGES

# Install Microsoft Edge
echo "Installing Microsoft Edge..."
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft.gpg
echo "deb [signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" | tee /etc/apt/sources.list.d/microsoft-edge.list
apt update && apt install -y microsoft-edge-stable

# Install Visual Studio Code
echo "Installing Visual Studio Code..."
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/packages.microsoft.gpg
echo "deb [signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list
apt update && apt install -y code

# Ensure Git is installed
echo "Installing Git..."
apt install -y git

# Configure SSH
if [ -f /etc/ssh/sshd_config ]; then
    echo "Configuring SSH..."
    sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config
    systemctl restart sshd
fi

# Set up firewall
echo "Configuring firewall..."
ufw allow OpenSSH
ufw enable

echo "System setup is complete. User 'king' has sudo privileges."
echo "Set up SSH keys manually for secure access: su - $USERNAME and run ssh-keygen -t rsa"
