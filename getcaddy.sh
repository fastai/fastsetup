#!/usr/bin/env bash

case "$OSTYPE" in
  darwin*)  name=mac_amd64; ;;
  linux*)   name=linux_amd64; ;;
  msys*)    name=windows_amd64; ;;
  *)        echo "unknown: $OSTYPE" ;;
esac

rel=$(wget -qO- https://api.github.com/repos/caddyserver/caddy/releases/latest | \
  jq -r '.assets | .[] | select(.name | contains ("'${name}'") and contains (".tar.gz"))  | .browser_download_url')
wget -qO- ${rel} | tar xz
