#!/bin/bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
echo 'eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)' >> ~/.config/fish/config.fish

## Terminal Utilities
sudo apt install tmux -y    

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

# Install Visual Studio Code
sudo apt install code

sudo apt install jq tree
snap install authy


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
curl -fsSLO https://www.rescuetime.com/installers/rescuetime_current_amd64.deb
sudo apt install ./rescuetime_current_amd64.deb
snap install drawio  
# Notion official app not available
curl -fsSLO https://roam-electron-deploy.s3.us-east-2.amazonaws.com/roam-research_0.0.18_amd64.deb
sudo apt install ./roam-research_0.0.18_amd64.deb

while read line; do code --install-extension "$line"; done < vscode-extensions.txt

#### Formal Methods
brew install tla-plus-toolbox
brew install alloy

#### Languages and Frameworks
brew install prest
brew install maven  
sudo add-apt-repository ppa:rabbitmq/rabbitmq-erlang
sudo apt update
sudo apt install elixir

brew install dotnet-sdk

rm -rf /usr/local/go && tar -C /usr/local -xzf go1.21.1.linux-amd64.tar.gz
fish_add_path /usr/local/go/bin

curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fish_add_path $HOME/.cargo/bin

curl -fL https://github.com/coursier/coursier/releases/latest/download/cs-x86_64-pc-linux.gz | gzip -d > cs && chmod +x cs && ./cs setup

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
https://zoom.us/client/5.14.7.2928/zoom_amd64.deb
snap install slack
snap install discord

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

sudo apt install postgresql-client-common
sudo apt-get install postgresql-client

https://docs.docker.com/desktop/install/ubuntu/

sudo apt-get update
sudo apt-get install ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

wget https://desktop.docker.com/linux/main/amd64/docker-desktop-4.20.0-amd64.deb

cat /etc/containers/registries.conf
unqualified-search-registries = ["docker.io"]

sudo ln -s /home/shrivatsa/.docker/desktop/docker.sock /var/run/docker.sock

sudo apt install default-jdk
sudo apt install openjdk-18-jre-headless

curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
fisher install jorgebucaran/nvm.fish
fisher install reitzig/sdkman-for-fish@v1.4.0

## Try out https://asdf-vm.com/

sudo wget -q -O - https://screenrec.com/download/pub.asc | sudo apt-key add -

sudo add-apt-repository 'deb https://screenrec.com/download/ubuntu stable main'

sudo apt update

sudo apt install screenrec