# fastsetup
> Setup all the things

First, do basic ubuntu configuration, such as updating packages, and turning on auto-updates:

```
sudo apt update && sudo apt -y install git
git clone https://github.com/fastai/fastsetup.git
cd fastsetup
./ubuntu-initial.sh
# wait a couple of minutes for reboot, then ssh back in
```

Then set up [dotfiles](https://github.com/fastai/dotfiles):

```
source dotfiles.sh
```

...and set up conda:

```
source setup-conda.sh
```
