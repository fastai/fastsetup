#!/usr/bin/env bash

case "$OSTYPE" in
  darwin*)  name=mac_amd64;ext='.tar.gz'; ;;
  linux*)   name=linux_amd64;ext='.tar.gz'; ;;
  msys*)    name=windows_amd64;ext='.zip'; ;;
  *)        echo "unknown: $OSTYPE" ;;
esac

rels=https://api.github.com/repos/caddyserver/caddy/releases/latest
rel=$(wget -qO- ${rels} | jq -r ".assets | .[] | select(.name | contains (\"${name}\") and contains (\"${ext}\"))  | .browser_download_url")

if [[ $name == "windows_amd64" ]]; then
  wget -qO- ${rel}
  unzip *.zip
else
  wget -qO- ${rel} | tar xz
fi
