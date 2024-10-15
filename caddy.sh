#!/usr/bin/env bash
set -e
fail () { echo $1 >&2; exit 1; }
[[ $(id -u) = 0 ]] || fail "Please run 'sudo $0'"

# To custom compile dns providers, include e.g.:
#  --with github.com/caddy-dns/azure --with github.com/caddy-dns/cloudflare --with github.com/caddy-dns/digitalocean --with github.com/caddy-dns/gandi --with github.com/caddy-dns/godaddy --with github.com/caddy-dns/googleclouddns --with github.com/caddy-dns/hetzner --with github.com/caddy-dns/linode --with github.com/caddy-dns/namecheap --with github.com/caddy-dns/netlify --with github.com/caddy-dns/ovh --with github.com/caddy-dns/powerdns --with github.com/caddy-dns/rfc2136 --with github.com/caddy-dns/route53 --with github.com/caddy-dns/vercel --with github.com/caddy-dns/vultr

wget -qO- https://caddy.fast.ai | bash
mv caddy /usr/bin/
wget -q https://github.com/caddyserver/dist/blob/master/init/caddy.service
mv caddy.service /etc/systemd/system/

groupadd --system caddy
useradd --system --gid caddy --create-home --home-dir /var/lib/caddy --shell /usr/sbin/nologin caddy
mkdir -p /etc/caddy
touch /etc/caddy/Caddyfile
chown -R caddy:caddy /etc/caddy

systemctl daemon-reload
systemctl enable caddy
systemctl start caddy
