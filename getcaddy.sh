#!/usr/bin/env bash

case "$OSTYPE" in
  darwin*)  name=mac_amd64; ;;
  linux*)   name=linux_amd64; ;;
  msys*)    name=windows_amd64; ;;
  *)        echo "unknown: $OSTYPE" ;;
esac

rel=$(gh release list -R caddyserver/caddy | grep Latest | cut -f 1)
wget -qO- "https://github.com/caddyserver/caddy/releases/latest/download/caddy_${rel:1}_${name}.tar.gz" | tar xz
