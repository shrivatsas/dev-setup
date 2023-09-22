/bin/bash -c "$(wget -qO- https://raw.githubusercontent.com/rbreaves/kinto/HEAD/install/linux.sh || curl -fsSL https://raw.githubusercontent.com/rbreaves/kinto/HEAD/install/linux.sh)"

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
echo 'eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)' >> ~/.config/fish/config.fish

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

# Cloud Utilities

# Kubernetes
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64  
sudo install minikube-linux-amd64 /usr/local/bin/minikube  

snap install kubectl --classic
kubectl version --client

# https://krew.sigs.k8s.io/docs/user-guide/setup/install
begin
  set -x; set temp_dir (mktemp -d); cd "$temp_dir" &&
  set OS (uname | tr '[:upper:]' '[:lower:]') &&
  set ARCH (uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/') &&
  set KREW krew-$OS"_"$ARCH &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/$KREW.tar.gz" &&
  tar zxvf $KREW.tar.gz &&
  ./$KREW install krew &&
  set -e KREW temp_dir &&
  cd -
end

set -gx PATH $PATH $HOME/.krew/bin
kubectl krew update
kubectl krew install ctx
kubectl krew install ns

snap install helm --classic

#### Apps
# brew install --cask zotero
snap install spotify
# Dropbox Manual https://www.dropbox.com/install-linux
snap install postman  
brew install rescuetime  
brew install drawio  
# Notion official app not available
curl -fsSLO https://roam-electron-deploy.s3.us-east-2.amazonaws.com/roam-research_0.0.18_amd64.deb
sudo apt install ./roam-research_0.0.18_amd64.deb

#### Formal Methods
brew install tla-plus-toolbox
brew install alloy

#### Languages and Frameworks
brew install prest
brew install maven  
brew install elixir
brew install dotnet-sdk 
brew install go
brew install cabal-install
brew install sbt
brew install leiningen
brew install ballerina
brew install adoptopenjdk8 # brew install --cask temurin8
nvm install --lts
jenv add /Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home/
brew install --cask graalvm/tap/graalvm-ce-java11
xattr -r -d com.apple.quarantine /Library/Java/JavaVirtualMachines/graalvm-ce-java11-21.0.0
jenv add /Library/Java/JavaVirtualMachines/graalvm-ce-java11-21.0.0/Contents/Home

#### Utilities
brew install atuin
echo 'eval "$(atuin init zsh)"' >> ~/.zshrc
brew install libpq
brew install pre-commit
brew install cairo pango
brew install difftastic

#### http://www.mediaatelier.com/CheatSheet/
brew install cheatsheet 

#### Communication
brew install zoom
brew install slack
brew install discord

#### References:
https://medium.com/@maxy_ermayank/developer-environment-setup-script-5fcb7b854acc

#### Themes : Solarizer : https://ethanschoonover.com/solarized/
curl https://ethanschoonover.com/solarized/files/solarized.zip -o solarized.zip
unzip solarized.zip -d ~/.solarized

#### TODO
#### IntelliJ plugins
wget -qO-  https://plugins.jetbrains.com/files/$(curl https://plugins.jetbrains.com/api/plugins/4415/updates | jq -r '.[0].file') | bsdtar -xvf- -C ~/.PhpStorm2018.3/config/plugins

#### Interesting projects
##### Glamorous Toolkit
curl https://dl.feenk.com/scripts/mac.sh | bash
