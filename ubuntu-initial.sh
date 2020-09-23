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
  cp -r "$PWD" ~/
  chown -R $SUDO_USER:$SUDO_USER ~/
fi

CODENAME=$(lsb_release -cs)
cat >> /etc/apt/sources.list << EOF
deb https://cli.github.com/packages $CODENAME main
deb http://ppa.launchpad.net/apt-fast/stable/ubuntu $CODENAME main
EOF
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C99B11DEB97541F0 1EE2FF37CA8DA16B
apt-get update

export DEBIAN_FRONTEND=noninteractive
apt-get -qy install apt-fast
cp apt-fast.conf /etc/
chown root:root /etc/apt-fast.conf
apt-fast -qy install python
apt-fast -qy install vim-nox python3-powerline rsync ubuntu-drivers-common python3-pip ack lsyncd wget bzip2 ca-certificates git rsync build-essential \
  software-properties-common curl grep sed dpkg libglib2.0-dev zlib1g-dev lsb-release tmux less htop exuberant-ctags openssh-client python-is-python3 \
  python3-pip python3-dev dos2unix gh pigz ufw bash-completion ubuntu-release-upgrader-core
env DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail apt-fast full-upgrade -qy -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold'
sudo apt -qy autoremove

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
if swapon /swapfile; then
  echo "/swapfile swap swap defaults 0 0" | tee -a /etc/fstab
else
  echo "Your administrator has disabled adding a swap file. This is just FYI, it is not an error."
  rm -f /swapfile
fi

perl -ni.bak -e 'print unless /^\s*(PermitEmptyPasswords|PermitRootLogin|PasswordAuthentication|ChallengeResponseAuthentication)/' /etc/ssh/sshd_config
cat << 'EOF' >> /etc/ssh/sshd_config
PasswordAuthentication no
ChallengeResponseAuthentication no
PermitEmptyPasswords no
PermitRootLogin no
EOF

systemctl reload ssh

# Enable firewall and allow ssh
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw --force enable

echo We need to reboot your machine to ensure kernel upgrades are installed
echo First, make sure you can login in a new terminal.
echo Open a new terminal, and login as $SUDO_USER
read -e -p "When you've confirmed you can login and run 'sudo', type 'y' to reboot. " REBOOT
if [[ $REBOOT = y* ]]; then
  shutdown -r now
else
  echo When ready, type: shutdown -r now
fi

