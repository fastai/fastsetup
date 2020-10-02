#!/usr/bin/env bash
set -e

if ! [[ $(id -u) = 0 ]] || [[ -z $SUDO_USER ]]; then
  echo "Please run 'sudo $0'" >&2
  exit 1
fi

if ! grep -q $(hostname) /etc/hosts; then
  echo "127.0.0.1 $(hostname)" >> /etc/hosts
fi

if [[ $SUDO_USER = "root" ]]; then
  echo "You are running as root, so let's create a new user for you"

  if [[ $NEWUSER ]]; then
    SUDO_USER=$NEWUSER
  else
    read -e -p "Please enter the username for your new user: " SUDO_USER
  fi
  if [[ -z $SUDO_USER ]]; then
    echo Empty username not permitted
    exit 1
  fi
  adduser $SUDO_USER --gecos ''
  usermod -aG sudo $SUDO_USER
  HOME=/home/$SUDO_USER
  echo "$SUDO_USER  ALL=(ALL:ALL) ALL" >> /etc/sudoers
  cp -r "$PWD" ~/
  chown -R $SUDO_USER:$SUDO_USER ~/
fi

if [[ $NEWPASS ]]; then
  echo "$SUDO_USER:$NEWPASS" | chpasswd
else
  read -e -p "We recommend setting your password. Set it now? [y/n] " -i y SETPASS
  if [[ $SETPASS = y* ]]; then
    passwd $SUDO_USER
  fi
fi
echo 'Defaults        timestamp_timeout=3600' >> /etc/sudoers

if [[ ! -s ~/.ssh/authorized_keys ]]; then
  if [[ -z $PUB_KEY ]]; then
    read -e -p "Please paste your public key here: " PUB_KEY
  fi
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh
  echo $PUB_KEY > ~/.ssh/authorized_keys
  chmod 600 ~/.ssh/authorized_keys
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
cp logrotate.conf apt-fast.conf /etc/
cp journald.conf /etc/systemd/
cp 50unattended-upgrades 10periodic /etc/apt/apt.conf.d/
if [[ -z $EMAIL ]]; then
  read -e -p "Enter your email address: " EMAIL
fi
cat >> /etc/apt/apt.conf.d/50unattended << EOF
Unattended-Upgrade::Mail "$EMAIL";
EOF
if [[ -z $AUTO_REBOOT ]]; then
  read -e -p "Reboot automatically when required for upgrades? [y/n] " -i y AUTO_REBOOT
fi
if [[ $AUTO_REBOOT = y* ]]; then
  echo 'Unattended-Upgrade::Automatic-Reboot "true";' >> /etc/apt/apt.conf.d/50unattended
fi

chown root:root /etc/{logrotate,apt-fast}.conf /etc/systemd/journald.conf /etc/apt/apt.conf.d/{50unattended-upgrades,10periodic}

apt-fast -qy install python
apt-fast -qy install vim-nox python3-powerline rsync ubuntu-drivers-common python3-pip ack lsyncd wget bzip2 ca-certificates git build-essential \
  software-properties-common curl grep sed dpkg libglib2.0-dev zlib1g-dev lsb-release tmux less htop exuberant-ctags openssh-client python-is-python3 \
  python3-pip python3-dev dos2unix gh pigz ufw bash-completion ubuntu-release-upgrader-core unattended-upgrades cpanminus libmime-lite-perl mailutils
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

# This is often used to setup passwordless sudo; so disable it
rm -f /etc/sudoers.d/90-cloud-init-users

# Enable firewall and allow ssh
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw --force enable

echo 'We need to reboot your machine to ensure kernel upgrades are installed'
echo 'First, make sure you can login in a new terminal, and that you can run `sudo -i`.'
echo "Open a new terminal, and login as $SUDO_USER"
if [[ -z $REBOOT ]]; then
  read -e -p 'When you have confirmed you can login and run `sudo -i`, type "y" to reboot. ' REBOOT
fi
if [[ $REBOOT = y* ]]; then
  shutdown -r now
else
  echo You chose not to reboot now. When ready, type: shutdown -r now
fi
