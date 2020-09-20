#!/usr/bin/env bash
set -e

sudo add-apt-repository -y ppa:apt-fast/stable
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install apt-fast
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0
sudo apt-add-repository -y https://cli.github.com/packages
sudo apt-fast -y install vim-nox python3-powerline rsync ubuntu-drivers-common python3-pip ack-grep lsyncd wget bzip2 ca-certificates git rsync build-essential \
  curl grep sed dpkg sudo libglib2.0-dev zlib1g-dev lsb-release tmux less htop ctags openssh-client python-is-python3 python3-pip python3-dev dos2unix gh pigz 
sudo apt-fast -y full-upgrade
sudo cp apt-fast.conf /etc/

cat << 'EOF' >> ~/.ssh/config
Host *
  ServerAliveInterval 60
  StrictHostKeyChecking no

Host github.com
  User git
  Port 22
  Hostname github.com
  TCPKeepAlive yes
  IdentitiesOnly yes
EOF
chmod 600 ~/.ssh/config

sudo cp 50unattended-upgrades /etc/apt/apt.conf.d/

# A swap file can be helpful if you don't have much RAM (i.e <1G)
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo "/swapfile swap swap defaults 0 0" | sudo tee -a /etc/fstab

# This will reboot your machine to ensure kernel upgrades are installed
sudo shutdown -r now
