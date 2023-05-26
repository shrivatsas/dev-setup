Linux Screen

/bin/bash -c "$(wget -qO- https://raw.githubusercontent.com/rbreaves/kinto/HEAD/install/linux.sh || curl -fsSL https://raw.githubusercontent.com/rbreaves/kinto/HEAD/install/linux.sh)"

## Terminal Utilities
sudo apt install tmux -y    
sudo apt install fish -y  
# Fisher
# curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher  
chsh -s /usr/bin/fish

mkdir -p ~/.config/fish

vim ~/.config/fish/config.fish

## Developer Utilities
sudo apt install git -y  

# jenv doesn't work with fish
# git clone https://github.com/jenv/jenv.git ~/.jenv

# Look for an alternate, maybe fisher based
# sudo apt install curl  
# https://github.com/jorgebucaran/nvm.fish  
# curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash  

# Install the packages required to compile Python
sudo apt-get update; sudo apt-get install --no-install-recommends make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

# Download pyenv code from github
git clone https://github.com/pyenv/pyenv.git ~/.pyenv

# Define environment variable PYENV_ROOT to point to the path where pyenv repo is cloned
echo "set --export PYENV_ROOT $HOME/.pyenv" > ~/.config/fish/conf.d/pyenv.fish

# Add $PYENV_ROOT/bin to your $PATH for access to the pyenv command-line utility
set -U fish_user_paths $HOME/.pyenv/bin $fish_user_paths

# Add pyenv init to your shell to enable shims and autocompletion.
echo -e '\n\n# pyenv init\nif command -v pyenv 1>/dev/null 2>&1\n  pyenv init - | source\nend' >> ~/.config/fish/config.fish

# Install pyenv-virtualenv
git clone https://github.com/pyenv/pyenv-virtualenv.git (pyenv root)/plugins/pyenv-virtualenv

# Enable virtualenv autocomplete
echo -e "\n# Enable virtualenv autocomplete\nstatus --is-interactive; and pyenv init - | source\nstatus --is-interactive; and pyenv virtualenv-init - | source\n" >> ~/.config/fish/conf.d/pyenv.fish

# Install Visual Studio Code
sudo apt install code

sudo apt install jq tree
snap install authy

sudo apt install podman podman-docker docker-compose
systemctl --user start podman.socket


