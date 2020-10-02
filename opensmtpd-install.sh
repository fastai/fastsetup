set -e
fail () { echo $1 >&2; exit 1; }
[[ $(id -u) = 0 ]] || fail "Please run as root (i.e 'sudo $0')"

apt-fast install -y dkimproxy procmail
apt remove -y amavisd-new
apt -y autoremove

$DOMAIN=$(hostname -d)
echo "domain  $DOMAIN" >> /etc/dkimproxy/dkimproxy_out.conf
echo DKIMPROXYGROUP=ssl-cert >> /etc/default/dkimproxy

systemctl restart opensmtpd.service
systemctl restart dkimproxy.service
echo "This is your public key - copy it into a TXT DNS record 'postfix._domainkey.$DOMAIN':"
perl -ne '!/^---/ && chomp && print' /var/lib/dkimproxy/public.key && echo
