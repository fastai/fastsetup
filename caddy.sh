#!/usr/bin/env bash
set -e
fail () { echo $1 >&2; exit 1; }
[[ $(id -u) = 0 ]] || fail "Please run 'sudo $0'"

case "$OSTYPE" in
  darwin*)  name=mac_amd64; ;;
  linux*)   name=linux_amd64; ;;
  *)        echo "unknown: $OSTYPE" ;;
esac

rel=$(gh release list -R caddyserver/caddy | grep Latest | cut -f 1)
wget -qO- "https://github.com/caddyserver/caddy/releases/latest/download/caddy_${rel:1}_${name}.tar.gz" | tar xz
mv caddy /usr/bin/

groupadd --system caddy
useradd --system --gid caddy --create-home --home-dir /var/lib/caddy --shell /usr/sbin/nologin caddy
mkdir -p /etc/caddy
touch /etc/caddy/Caddyfile
chown -R caddy:caddy /etc/caddy

systemctl daemon-reload
systemctl enable caddy
systemctl start caddy
