cd
shopt -s expand_aliases
alias config="/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME"
echo ".cfg" >> .gitignore
read -e -p "Please paste a HTTPS link to your dotfiles repository (or press enter to use defaults): " DOTFILES_URL
[[ -z $DOTFILES_URL ]] && DOTFILES_URL=https://github.com/fastai/dotfiles.git
git clone --bare $DOTFILES_URL .cfg/
config checkout
config config --local status.showUntrackedFiles no
if [[ -s ~/.vimrc ]]; then
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  vim +PluginInstall +qall
fi
if [[ -f ~/.bashrc.local ]]; then
  echo "source ~/.bashrc.local" >> ~/.bashrc
fi
if [[ -f ~/.bash_profile ]]; then
  grep -q 'source ~/.bashrc' ~/.bash_profile 2>&1 || echo "source ~/.bashrc" >> ~/.bash_profile;
else
  echo "Creating '.bash_profile'..."
  echo "source ~/.bashrc" >> ~/.bash_profile
fi
. ~/.bashrc

[[ -z $NAME  ]] && read -e -p "Enter your name (for git configuration): " NAME
[[ -z $EMAIL ]] && read -e -p "Enter your email (for git configuration): " EMAIL
[[ $NAME  ]] && git config --global user.name "$NAME"
[[ $EMAIL ]] && git config --global user.email "$EMAIL"
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=3600'

cd -

