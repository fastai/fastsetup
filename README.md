# fastsetup
> Setup all the things

First, do basic ubuntu configuration, such as updating packages, and turning on auto-updates:

## If you are running in WSL, run the correct sections below.

### non-WSL-only

```
sudo apt update && sudo apt -y install git
git clone https://github.com/fastai/fastsetup.git
cd fastsetup
sudo ./ubuntu-initial.sh
# wait a couple of minutes for reboot, then ssh back in
```

### WSL-only

```
sudo apt update && sudo apt -y install git
git clone https://github.com/fastai/fastsetup.git
cd fastsetup
sudo ./ubuntu-wsl.sh
```

Then, optionally, set up [dotfiles](https://github.com/fastai/dotfiles):

    source dotfiles.sh

...and set up conda:

```
source setup-conda.sh
. ~/.bashrc
conda install -yq mamba
```

To set up email:

    sudo ./opensmtpd-install.sh

To test email, create a text file `msg` containing a message to send, then send it with:

    cat msg |  mail -r "x@$(hostname -d)" -s 'subject' EMAIL_ADDR

Replace `EMAIL_ADDR` with an address to send to. You can get a useful testing address from [mail-tester](https://www.mail-tester.com/).

To install NVIDIA drivers, if required:

### non-WSL-only:

```
ubuntu-drivers devices
sudo apt-fast install -y nvidia-XXX
sudo modprobe nvidia
nvidia-smi
```

### WSL-only:

Install the latest NVIDIA driver on your Windows PC running WSL
Then do a special install of cuda

```
sudo apt-key del 7fa2af80
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb
sudo dpkg -i cuda-keyring_1.0-1_all.deb
wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin
sudo mv cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/11.7.0/local_installers/cuda-repo-wsl-ubuntu-11-7-local_11.7.0-1_amd64.deb
sudo dpkg -i cuda-repo-wsl-ubuntu-11-7-local_11.7.0-1_amd64.deb
sudo apt-get update
sudo apt-fast install -y cuda
nvidia-smi
```

(WSL-only): Don't worry if nvidia-smi reports
 "Internal Error" under the "Processes" heading.

If it's working, you should still see part of your GPU name,
and how much memory is available in the first heading.
