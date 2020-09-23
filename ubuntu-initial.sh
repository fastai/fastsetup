#!/usr/bin/env bash
set -e

if ! [[ $(id -u) = 0 ]] || [[ -z $SUDO_USER ]]; then
  echo "Please run 'sudo $0'" >&2
  exit 1
fi

if ! grep -q $(hostname) /etc/hosts; then
  echo "127.0.0.1 $(hostname)" >> /etc/hosts
fi

read -e -p "We recommend setting your password. Set it now? [y/n] " -i y SETPASS
if [[ $SETPASS = y* ]]; then
  passwd
fi

if [[ ! -f ~/.ssh/authorized_keys ]]; then
  read -e -p "Please paste your public key here: " PUB_KEY
  mkdir ~/.ssh
  chmod 700 ~/.ssh
  echo $PUB_KEY > ~/.ssh/authorized_keys
  chmod 400 ~/.ssh/authorized_keys
fi

if [[ $SUDO_USER = "root" ]]; then
  echo "You are running as root, so let's create a new user for you"

  read -e -p "Please enter the username for your new user: " SUDO_USER
  if [[ -z $SUDO_USER ]]; then
    echo Empty username not permitted
    exit 1
  fi
  adduser $SUDO_USER --gecos ''
  HOME=/home/$SUDO_USER
  mkdir ~/.ssh
  chmod 700 ~/.ssh
  cp /root/.ssh/authorized_keys ~/.ssh/
  chmod 400 ~/.ssh/authorized_keys
  echo "$SUDO_USER  ALL=(ALL:ALL) ALL" >> /etc/sudoers
fi

export DEBIAN_FRONTEND=noninteractive
apt-add-repository -y https://cli.github.com/packages
apt-add-repository -y ppa:apt-fast/stable
apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0
apt-get update
apt-get -y install apt-fast
cp apt-fast.conf /etc/
chown root:root /etc/apt-fast.conf
apt-fast -y install vim-nox python3-powerline rsync ubuntu-drivers-common python3-pip ack lsyncd wget bzip2 ca-certificates git rsync build-essential \
  curl grep sed dpkg libglib2.0-dev zlib1g-dev lsb-release tmux less htop exuberant-ctags openssh-client python-is-python3 python3-pip python3-dev dos2unix gh pigz 
apt-fast -y full-upgrade

mkdir -p ~/.ssh
chmod 700 ~/.ssh
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
chown -R $SUDO_USER:$SUDO_USER ~/.ssh

cp 50unattended-upgrades /etc/apt/apt.conf.d/

# A swap file can be helpful if you don't have much RAM (i.e <1G)
fallocate -l 1G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile swap swap defaults 0 0" | tee -a /etc/fstab

cat << 'EOF' >> ~/.ssh/config
PasswordAuthentication no
ChallengeResponseAuthentication no
PermitEmptyPasswords no
ForwardX11 yes
PermitRootLogin no
EOF

sudo systemctl reload ssh

# Enable firewall and allow ssh
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw --force enable

echo We need to reboot your machine to ensure kernel upgrades are installed
echo First, make sure you can login in a new terminal.
echo Open a new terminal, and login as $SUDO_USER
read -e -p "When you've confirmed you can login and run 'sudo', type 'y' to reboot. " REBOOT
if [[ $REBOOT = y* ]]; then
  shutdown -r now
else
  echo When ready, type: shutdown -r now
fi

