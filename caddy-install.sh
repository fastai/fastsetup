#!/usr/bin/env bash
set -e
fail () { echo $1 >&2; exit 1; }
[[ $(id -u) = 0 ]] || fail "Please run as root (i.e 'sudo $0')"

export DEBIAN_FRONTEND=noninteractive

sudo apt update

# install caddy
# source: https://caddyserver.com/docs/download#debian-ubuntu-raspbian
sudo tee -a /etc/apt/sources.list.d/caddy-fury.list <<EOF 
deb [trusted=yes] https://apt.fury.io/caddy/ /
EOF

sudo apt update
sudo apt install -y caddy

cp Caddyfile ~/

# Caddy can be set up as a service: https://caddyserver.com/docs/install#install
# but if it's installed from apt it does not seem to be needed
