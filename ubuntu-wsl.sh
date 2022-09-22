#!/usr/bin/env bash
set -e
fail () { echo $1 >&2; exit 1; }
[[ $(id -u) = 0 ]] || [[ -z $SUDO_USER ]] || fail "Please run 'sudo $0'"

echo 'Defaults        timestamp_timeout=3600' >> /etc/sudoers

CODENAME=$(lsb_release -cs)
cat >> /etc/apt/sources.list << EOF
deb http://ppa.launchpad.net/apt-fast/stable/ubuntu $CODENAME main
EOF
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1EE2FF37CA8DA16B
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
apt-get update

export DEBIAN_FRONTEND=noninteractive
apt-get -qy install apt-fast
cp apt-fast.conf /etc/
chown root:root /etc/apt-fast.conf

apt-fast -qy install python
apt-fast -qy install vim-nox python3-powerline rsync ubuntu-drivers-common python3-pip ack lsyncd wget bzip2 ca-certificates git build-essential \
  software-properties-common curl grep sed dpkg libglib2.0-dev zlib1g-dev lsb-release tmux less htop exuberant-ctags openssh-client python-is-python3 \
  python3-pip python3-dev dos2unix gh pigz ufw bash-completion ubuntu-release-upgrader-core unattended-upgrades cpanminus libmime-lite-perl \
  opensmtpd mailutils cron
env DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail apt-fast full-upgrade -qy -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold'
sudo apt -qy autoremove

perl -ni.bak -e 'print unless /^\s*(PermitEmptyPasswords|PermitRootLogin|PasswordAuthentication|ChallengeResponseAuthentication)/' /etc/ssh/sshd_config
cat << 'EOF' >> /etc/ssh/sshd_config
PasswordAuthentication no
ChallengeResponseAuthentication no
PermitEmptyPasswords no
PermitRootLogin no
EOF
# broken because WSL doesn't yet support systemd
# Support was just added, but not yet out of preview
# see here for details:
# https://ubuntu.com/blog/ubuntu-wsl-enable-systemd
#
#systemctl reload ssh
service ssh restart

python -m pip install pip -Uq
