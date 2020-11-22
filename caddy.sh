#!/usr/bin/env bash
set -e
fail () { echo $1 >&2; exit 1; }
[[ $(id -u) = 0 ]] || fail "Please run 'sudo $0'"

source getcaddy.sh
mv caddy /usr/bin/

groupadd --system caddy
useradd --system --gid caddy --create-home --home-dir /var/lib/caddy --shell /usr/sbin/nologin caddy
mkdir -p /etc/caddy
touch /etc/caddy/Caddyfile
chown -R caddy:caddy /etc/caddy

systemctl daemon-reload
systemctl enable caddy
systemctl start caddy
