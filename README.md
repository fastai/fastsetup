# fastsetup
> Setup all the things

First, do basic ubuntu configuration, such as updating packages, and turning on auto-updates:

```
sudo apt update && sudo apt -y install git
git clone https://github.com/fastai/fastsetup.git
cd fastsetup
sudo ./ubuntu-initial.sh
# wait a couple of minutes for reboot, then ssh back in
```

Then set up [dotfiles](https://github.com/fastai/dotfiles):

    source dotfiles.sh

...and set up conda:

    source setup-conda.sh

To set up email:

    sudo ./opensmtpd-install.sh

To test email, create a text file `msg` containing a message to send, then send it with:

    cat msg |  mail -r "x@$(hostname -d)" -s 'subject' EMAIL_ADDR

Replace `EMAIL_ADDR` with an address to send to. You can get a useful testing address from [mail-tester](https://www.mail-tester.com/).

To set up Caddy as a reverse proxy and certificates manager:

    sudo ./caddy-install.sh
