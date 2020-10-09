#!/usr/bin/env bash
set -e
fail () { echo $1 >&2; exit 1; }
[[ $(id -u) = 0 ]] || fail "Please run as root (i.e 'sudo $0')"

export DEBIAN_FRONTEND=noninteractive

sudo apt update

# install caddy
# source: https://caddyserver.com/docs/download#debian-ubuntu-raspbian
if [[ ! -a /etc/apt/sources.list.d/caddy-fury.list ]]; then
  sudo tee -a /etc/apt/sources.list.d/caddy-fury.list <<EOF 
deb [trusted=yes] https://apt.fury.io/caddy/ /
EOF
fi

sudo apt update
sudo apt install -y caddy

CADDYAUTH=""

read -e -p "We recommend setting a basic HTTP auth in Caddy. Set it now? [y/n] " -i y
if [[ $REPLY = y* ]]; then
  [[ -z $CADDYUSER ]] && read -e -p "Enter user for HTTP auth: " CADDYUSER
  [[ -z $CADDYPASSWD ]] && read -e -p "Enter password for HTTP auth: " CADDYPASSWD
  export CADDYHASHED=$(caddy hash-password --plaintext "$CADDYPASSWD")
  CADDYAUTH=$(cat <<EOF
  # basic auth for the server, to change it:
  # 1. run the command: caddy hash-password
  # 2. enter the password
  # 3. copy the hash and replace the one below
  # 4. replace the user with the username you want
  basicauth {
      $CADDYUSER $CADDYHASHED
  }
EOF
)
fi

[[ -z $DOMAIN ]] && read -e -p "Enter domain name to set: " DOMAIN
# strip www. prefix from the domain name if it exists
DOMAIN=${DOMAIN#"www."}
[[ -z $UPSTREAMPORT ]] && read -e -p "Enter the port where your app is running: " UPSTREAMPORT

grep -q $DOMAIN ~/Caddyfile && fail "This domain already exists in the Caddyfile"

cat >> ~/Caddyfile << EOF
$DOMAIN {
  encode zstd gzip

  # if you want to lead balance between different
  # replicas of the app, you can add more <address>:<port>
  # and caddy will load balance between them
  reverse_proxy localhost:$UPSTREAMPORT {
	lb_policy least_conn
  }

$CADDYAUTH

  # log connections to the server
  log {
    output file /var/log/caddy.$DOMAIN.log {
        roll_size 20MiB
	roll_keep 2
	roll_keep_for 720h
    }
  }
}

www.$DOMAIN {
  redir https://$DOMAIN{uri} permanent
}
EOF

echo "Openning ports 80(http)/443(https) in the firewall"
sudo ufw allow 80,443/tcp

# read -e -p "Do you want to start Caddy now? [y/n] " -i y
# if [[ $REPLY = y* ]]; then
# caddy starts automatically after installation when installed
# from a package manager
# so only a reload is needed
cd
caddy reload
# fi

echo "If you want to change the Caddyfile, run 'caddy reload' afterwards"


# Caddy can be set up as a service: https://caddyserver.com/docs/install#install
# but if it's installed from apt it does not seem to be needed
