set -eou pipefail

cd

case "$OSTYPE" in
  darwin*)  DOWNLOAD=https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh; ;;
  linux*)   DOWNLOAD=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh; ;;
  *)        echo "unknown: $OSTYPE" ;;
esac

case "$SHELL" in
  /bin/zsh*)   SHELL_NAME=zsh; ;;
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

wget –quiet $DOWNLOAD
bash Miniconda3-latest*.sh -b
~/miniconda3/bin/conda init $SHELL_NAME
rm Miniconda3-latest*.sh

. ~/.bashrc

conda install -yq mamba

cd -
