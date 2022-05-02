#!/usr/bin/env bash
set -eou pipefail

case "$OSTYPE" in
  darwin*)
    case $(uname -m) in
      arm64)  DOWNLOAD=https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-MacOSX-arm64.sh; ;;
      *)      DOWNLOAD=https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-MacOSX-x86_64.sh; ;;
    esac ;;
  linux*)     DOWNLOAD=https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh; ;;
  *)          echo "unknown: $OSTYPE" ;;
esac

case "$SHELL" in
  /bin/zsh*)   SHELL_NAME=zsh; ;;
  /bin/bash*)  SHELL_NAME=bash ;;
  /usr/local/bin/fish*) SHELL_NAME=fish ;;
  *)        echo "unknown: $SHELL" ;;
esac

echo Downloading installer...
curl -LO --no-progress-meter $DOWNLOAD
bash Mambaforge-*.sh -b

~/mambaforge/bin/conda init $SHELL_NAME

echo Please close and reopen your terminal.

