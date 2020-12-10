#### Homebrew  
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew update

#### iTerm2  
brew cask install iTerm2

#### ZSH and oh-my-zsh  
brew install zsh  
chsh -s /bin/zsh && sudo chsh -s /bin/zsh   
curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh  

#### Firefox  
brew install homebrew/cask-versions/firefox-developer-edition  

#### Package Managers  
brew install nvm jenv  
brew cask install miniconda  

brew install git  

brew install mysql redis  
brew services start mysql redis  
brew cask install dbeaver-community  

#### IDEs and Editors
brew cask install visual-studio-code  
cat ./vscode-extensions.txt | xargs -L1 code — install-extension
brew cask install intellij-idea

#### Utilities
brew install jq

#### Infra
brew cask install docker
brew cask install vagrant
brew cask install virtualbox
brew cask install vagrant-manager

#### Cloud
brew install awscli
brew install azure-cli

#### Apps
brew install dropbox
brew cask install postman  
brew cask install rescuetime  
brew cask install drawio  

#### Formal Methods
brew cask install tla-plus-toolbox
brew cask install alloy

#### Languages and Frameworks
brew install maven  
brew install elixir
brew cask install dotnet-sdk 
brew install go
brew install cabal-install
brew install sbt
brew install leiningen
brew install adoptopenjdk8
env add /Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home/
brew cask install graalvm/tap/graalvm-ce-java11
jenv add /Library/Java/JavaVirtualMachines/graalvm-ce-java11-20.3.0/Contents/Home

#### http://www.mediaatelier.com/CheatSheet/
brew cask install cheatsheet 

#### Communication
brew cask install zoomus
brew install slack

#### References:
https://medium.com/@maxy_ermayank/developer-environment-setup-script-5fcb7b854acc

#### TODO
#### IntelliJ plugins
wget -qO-  https://plugins.jetbrains.com/files/$(curl https://plugins.jetbrains.com/api/plugins/4415/updates | jq -r '.[0].file') | bsdtar -xvf- -C ~/.PhpStorm2018.3/config/plugins
