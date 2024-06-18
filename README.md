# fastsetup
> Setup all the things

First, do basic ubuntu configuration, such as updating packages, and turning on auto-updates:

```
sudo apt update && sudo apt -y install git
git clone https://github.com/fastai/fastsetup.git
cd fastsetup
sudo ./ubuntu-initial.sh
# wait a couple of minutes for reboot, then ssh back in
# If you're using WSL (Windows) use `sudo ./ubuntu-wsl.sh` instead of the above line
```

Then, optionally, set up [dotfiles](https://github.com/fastai/dotfiles):

    source dotfiles.sh

...and set up conda:

```
source setup-conda.sh
. ~/.bashrc
conda install -yq mamba -c conda-forge
```

To set up email:

    sudo ./opensmtpd-install.sh

To test email, create a text file `msg` containing a message to send, then send it with:

    cat msg |  mail -r "x@$(hostname -d)" -s 'subject' EMAIL_ADDR

Replace `EMAIL_ADDR` with an address to send to. You can get a useful testing address from [mail-tester](https://www.mail-tester.com/).

## NVIDIA drivers

To install NVIDIA drivers, if required:

```
ubuntu-drivers devices
sudo apt-fast install -y nvidia-XXX{-server}
sudo modprobe nvidia
nvidia-smi
```

### WSL-only:

Install the latest NVIDIA driver on your Windows PC running WSL
Then do a special install of cuda

```
sudo apt-key del 7fa2af80
wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin
sudo mv cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda-repo-wsl-ubuntu-11-8-local_11.8.0-1_amd64.deb
sudo dpkg -i cuda-repo-wsl-ubuntu-11-8-local_11.8.0-1_amd64.deb
sudo cp /var/cuda-repo-wsl-ubuntu-11-8-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-fast install -y cuda
nvidia-smi
```

(WSL-only): Don't worry if nvidia-smi reports
 "Internal Error" under the "Processes" heading.

If it's working, you should still see part of your GPU name,
and how much memory is available in the first heading.
