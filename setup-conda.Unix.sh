#!/usr/bin/env bash
set -eou pipefail

case "$OSTYPE" in
  darwin*)
    case $(uname -m) in
      arm64)  DOWNLOAD=https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh; ;;
      *)      DOWNLOAD=https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh; ;;
    esac ;;
  linux*)
    case $(uname -m) in
      aarch64) DOWNLOAD=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh; ;;
      *)       DOWNLOAD=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh; ;;
      esac ;;
  *)          echo "unknown: $OSTYPE" ;;
esac

case "$SHELL" in
  *bin/zsh*)   SHELL_NAME=zsh; ;;
  *bin/bash*)  SHELL_NAME=bash ;;
  *bin/fish*) SHELL_NAME=fish ;;
  *)        echo "unknown: $SHELL" ;;
esac

echo Downloading installer...
curl -LO --no-progress-meter $DOWNLOAD
bash Miniconda3-*.sh -b

~/miniconda3/bin/conda init $SHELL_NAME

echo Please close and reopen your terminal.

