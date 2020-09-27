cd
shopt -s expand_aliases
alias config="/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME"
echo ".cfg" >> .gitignore
read -e -p "Please paste a HTTPS link to your dotfiles repository (or press enter to use defaults): " DOTFILES_URL
if [[ -z $DOTFILES_URL ]]; then
  DOTFILES_URL=https://github.com/fastai/dotfiles.git 
fi
git clone --bare $DOTFILES_URL .cfg/
config checkout
config config --local status.showUntrackedFiles no
if [[ -s ~/.vimrc ]]; then                                                      
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  vim +PluginInstall +qall > /dev/null                                          
fi                                                                              
echo "source ~/.bashrc.local" >> ~/.bashrc
. ~/.bashrc

if [[ -z $NAME ]]; then
  read -e -p "Enter your name (for git configuration): " NAME
fi
if [[ $NAME ]]; then
  git config --global user.name "$NAME"
fi
if [[ -z $EMAIL ]]; then
  read -e -p "Enter your email (for git configuration): " EMAIL
fi
if [[ $EMAIL ]]; then
  git config --global user.email "$EMAIL"
fi

cd -
