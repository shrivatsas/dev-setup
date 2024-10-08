### M1 / arm64 support
#### Homebrew  
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"  
brew update

xcode-select --install  
sudo softwareupdate --install-rosetta  

#### iTerm2  
brew install iTerm2 tmux  
brew install --cask warp  

#### ZSH and oh-my-zsh  
brew install zsh  
chsh -s /bin/zsh && sudo chsh -s /bin/zsh   
curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh
brew install zsh-autosuggestions  
echo "source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc  
brew install zoxide
brew install fzf

#### Firefox  
brew install homebrew/cask-versions/firefox-developer-edition  

#### Package Managers  
brew install nvm jenv  
echo "eval '$(jenv init -)'" >> ~/.zshrc
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

brew install pyenv
echo "eval '$(pyenv init -)'" >> ~/.zshrc
echo "alias pe='source ./venv/bin/activate'" >> ~/.zshrc
pyenv install 3.8

brew install git  
echo "alias gs='git status' gc='git checkout' ga='git add' gsl='git stash list' gss='git stash save' gm='git commit -m' gd='git diff'" >> ~/.zshrc

brew install altinity/clickhouse/clickhouse
brew install mysql redis  
brew services start mysql redis  
brew install dbeaver-community  
# Copy .dbeaver directory from old installation if available
# https://dbeaver.com/docs/wiki/Admin-Manage-Connections/ 

#### IDEs and Editors
brew install visual-studio-code
cat ./vscode-extensions.txt | xargs -L1 code —-install-extension
brew install intellij-idea-ce
brew install visual-studio
brew install --cask cursor

#### Utilities
brew install jq tree libevent
brew install microsoft-excel
brew install authy
brew install --cask wireshark wireshark-chmodbpf
brew install proxyman
brew install telnet

#### Infra
brew install --cask docker
brew install docker-compose
brew install vagrant
brew install virtualbox
brew install vagrant-manager

#### Cloud
brew install awscli
curl -Lo /usr/local/bin/ecs-cli https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-darwin-amd64-latest
chmod +x /usr/local/bin/ecs-cli
brew install azure-cli  
brew install terraform  
brew install tfenv  
TFENV_ARCH=arm64 tfenv install 0.14.10  
brew install kreuzwerker/taps/m1-terraform-provider-helper  
m1-terraform-provider-helper activate  
m1-terraform-provider-helper install hashicorp/template -v v2.2.0  
brew tap common-fate/granted
brew install granted

#### Kubernetes
brew install minikube
brew install kubectx
brew install helm

#### Apps
brew install --cask zotero
brew install --cask spotify
brew install dropbox
brew install postman  
brew install rescuetime  
brew install drawio  
brew install notion
brew install --cask roam-research

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
brew install --cask --no-quarantine stretchly

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
