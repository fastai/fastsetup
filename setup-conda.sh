#!/usr/bin/env bash
set -e

cd

case "$OSTYPE" in
  darwin*)  DOWNLOAD=https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh; RC_FILE=.bash_profile ;;
  linux*)   DOWNLOAD=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh; RC_FILE=.bashrc  ;;
  *)        echo "unknown: $OSTYPE" ;;
esac

case "$SHELL" in
  /bin/zsh*)   SHELL_NAME=zsh; RC_FILE=.zshrc ;;
  /bin/bash*)  SHELL_NAME=bash ;;
  /usr/local/bin/fish*) SHELL_NAME=fish ;;
  *)        echo "unknown: $SHELL" ;;
esac

cat << EOF > .condarc
channels:
  - fastai
  - pytorch
  - defaults
channel_priority: strict
EOF

wget $DOWNLOAD
bash Miniconda3-latest*.sh -b
~/miniconda3/bin/conda init $SHELL_NAME
rm Miniconda3-latest*.sh

perl -n  -e 'print if     />>> conda/../<<< conda/' $RCFILE > .condainit
perl -ni -e 'print unless />>> conda/../<<< conda/' $RCFILE
echo source ~/.condainit >> $RCFILE
source ~/.condainit

conda install -y mamba
