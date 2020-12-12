#### Homebrew  
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew update

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
brew install --cask intellij-idea
brew install --cask visual-studio

#### Utilities
brew install jq tree libevent
brew install --cask microsoft-excel

#### Infra
brew install --cask docker
brew install docker-compose
brew install --cask vagrant
brew install --cask virtualbox
brew install --cask vagrant-manager

#### Cloud
brew install awscli
brew install azure-cli

#### Apps
brew install dropbox
brew install --cask postman  
brew install --cask rescuetime  
brew install --cask drawio  

#### Formal Methods
brew install --cask tla-plus-toolbox
brew install --cask alloy

#### Languages and Frameworks
brew install maven  
brew install elixir
brew install --cask dotnet-sdk 
brew install go
brew install cabal-install
brew install sbt
brew install leiningen
brew install ballerina
brew install adoptopenjdk8
jenv add /Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home/
brew install --cask graalvm/tap/graalvm-ce-java11
xattr -r -d com.apple.quarantine /Library/Java/JavaVirtualMachines/graalvm-ce-java11-20.3.0
jenv add /Library/Java/JavaVirtualMachines/graalvm-ce-java11-20.3.0/Contents/Home

#### http://www.mediaatelier.com/CheatSheet/
brew install --cask cheatsheet 

#### Communication
brew install --cask zoomus
brew install slack

#### References:
https://medium.com/@maxy_ermayank/developer-environment-setup-script-5fcb7b854acc

#### TODO
#### IntelliJ plugins
wget -qO-  https://plugins.jetbrains.com/files/$(curl https://plugins.jetbrains.com/api/plugins/4415/updates | jq -r '.[0].file') | bsdtar -xvf- -C ~/.PhpStorm2018.3/config/plugins
