#### Homebrew  
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"  
brew update

xcode-select --install

#### iTerm2  
brew install --cask iTerm2

#### ZSH and oh-my-zsh  
brew install zsh  
chsh -s /bin/zsh && sudo chsh -s /bin/zsh   
curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh  

#### Firefox  
brew install homebrew/cask-versions/firefox-developer-edition  

#### Package Managers  
brew install nvm jenv  
brew install --cask miniconda  
conda create -n py3.8 python=3.8  
conda init zsh
# Might need a restart of the shell  
conda activate py3.8
cat ./conda-packages.txt | xargs -L1 conda install  

brew install git  
echo "alias gs='git status' gc='git checkout' ga='git add' gsl='git stash list' gss='git stash save' gm='git commit -m' gd='git diff'" >> ~/.zshrc

brew install mysql redis  
brew services start mysql redis  
brew install --cask dbeaver-community  
# Copy .dbeaver directory from old installation if available
# https://dbeaver.com/docs/wiki/Admin-Manage-Connections/

#### IDEs and Editors
brew install --cask visual-studio-code
cat ./vscode-extensions.txt | xargs -L1 code —-install-extension
brew install --cask intellij-idea-ce
brew install --cask visual-studio

#### Utilities
brew install jq tree libevent
brew install --cask microsoft-excel
brew install --cask authy

#### Infra
brew install --cask docker
brew install docker-compose
brew install --cask vagrant
brew install --cask virtualbox
brew install --cask vagrant-manager

#### Cloud
brew install awscli
sudo curl -Lo /usr/local/bin/ecs-cli https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-darwin-amd64-latest
sudo chmod +x /usr/local/bin/ecs-cli
brew install azure-cli
brew install terraform

#### Apps
brew install dropbox
brew install --cask postman  
brew install --cask rescuetime  
brew install --cask drawio  
brew install --cask notion

#### Formal Methods
brew install --cask tla-plus-toolbox
brew install --cask alloy

#### Languages and Frameworks
brew install prest
brew install maven  
brew install elixir
brew install --cask dotnet-sdk 
brew install go
brew install cabal-install
brew install sbt
brew install leiningen
brew install ballerina
brew install adoptopenjdk8
nvm install --lts
jenv add /Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home/
brew install --cask graalvm/tap/graalvm-ce-java11
xattr -r -d com.apple.quarantine /Library/Java/JavaVirtualMachines/graalvm-ce-java11-21.0.0
jenv add /Library/Java/JavaVirtualMachines/graalvm-ce-java11-21.0.0/Contents/Home

#### Utilities
brew install pre-commit
brew install cairo pango

#### http://www.mediaatelier.com/CheatSheet/
brew install --cask cheatsheet 

#### Communication
brew install zoom
brew install slack

#### References:
https://medium.com/@maxy_ermayank/developer-environment-setup-script-5fcb7b854acc

#### Themes : Solarizer : https://ethanschoonover.com/solarized/
wget ethanschoonover.com/solarized/files/solarized.zip
mv solarized.zip -d ~/
mv ~/solarized ~/.solarized

#### TODO
#### IntelliJ plugins
wget -qO-  https://plugins.jetbrains.com/files/$(curl https://plugins.jetbrains.com/api/plugins/4415/updates | jq -r '.[0].file') | bsdtar -xvf- -C ~/.PhpStorm2018.3/config/plugins
