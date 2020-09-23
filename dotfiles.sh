cd
shopt -s expand_aliases
alias config="/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME"
echo ".cfg" >> .gitignore
git clone --bare https://github.com/fastai/dotfiles.git .cfg/
config checkout
config config --local status.showUntrackedFiles no
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
echo "source ~/.bashrc.local" >> ~/.bashrc
. ~/.bashrc
rm -f README.md

read -e -p "Enter your name (for git configuration): " NAME
if [[ $NAME ]]; then
  git config --global user.name $NAME
fi
read -e -p "Enter your email (for git configuration): " EMAIL
if [[ $EMAIL ]]; then
  git config --global user.email $EMAIL
fi

cd -
