#!/usr/bin/env bash
set -e
fail () { echo $1 >&2; exit 1; }
[[ $(id -u) = 0 ]] || fail "Please run as root (i.e 'sudo $0')"

apt-fast install -y dkimproxy procmail
apt remove -y amavisd-new
apt -y autoremove

DOMAIN=$(hostname -d)
[[ -z $ROOTMAIL ]] && read -e -p "What email address would you like to send root email to: " ROOTMAIL
echo "@: $ROOTMAIL" > /etc/aliases

mkdir -p /etc/smtpd/
[[ -z $SMTPPASS ]] && read -e -p "Enter password for accessing your SMTP server: " SMTPPASS
PASS=$(smtpctl encrypt "$SMTPPASS")
openssl req  -nodes -new -x509 -subj "/C=US/ST=CA/L=SF/O=$DOMAIN/OU=IT/CN=$DOMAIN" -keyout /etc/smtpd/smtpd.key -out /etc/smtpd/smtpd.crt
chown root:opensmtpd /etc/smtpd/*
chmod 640 /etc/smtpd/*
cp smtpd.conf /etc/
chmod 640 /etc/smtpd.conf
chown root:root /etc/smtpd.conf
perl -pi -e "s/SMTPPASS/$SMTPPASS/" /etc/smtpd.conf

echo "domain  $DOMAIN" >> /etc/dkimproxy/dkimproxy_out.conf
echo DKIMPROXYGROUP=ssl-cert >> /etc/default/dkimproxy

systemctl restart opensmtpd.service
systemctl restart dkimproxy.service

echo "If you want to open your mail server to external IPs, run 'sudo ufw allow 587'"
echo
echo "This is your public key - copy it into a TXT DNS record 'postfix._domainkey.$DOMAIN':"
perl -ne '!/^---/ && chomp && print' /var/lib/dkimproxy/public.key && echo

