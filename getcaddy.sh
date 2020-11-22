#!/usr/bin/env bash

case "$OSTYPE" in
  darwin*)  name=mac_amd64; ;;
  linux*)   name=linux_amd64; ;;
  msys*)    name=windows_amd64; ;;
  *)        echo "unknown: $OSTYPE" ;;
esac

rel=$(wget -qO- https://api.github.com/repos/caddyserver/caddy/releases/latest | jq -r '.assets | .[] | select(.name | contains ("${name}"))  | .browser_download_url')
wget -qO- "https://github.com/caddyserver/caddy/releases/latest/download/caddy_${rel:1}_${name}.tar.gz" | tar xz
