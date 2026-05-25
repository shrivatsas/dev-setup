### M1 / arm64 support
xcode-select --install

#### Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
brew update

#### iTerm2
brew install --cask iterm2
brew install tmux
brew install --cask alfred

#### ZSH and oh-my-zsh
brew install zsh
chsh -s /bin/zsh && sudo chsh -s /bin/zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
brew install --cask font-powerline-symbols
echo "ZSH_THEME='agnoster'" >> ~/.zshrc
brew install zsh-autosuggestions
echo "source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc
brew install zoxide fzf

#### Firefox
brew install --cask firefox@developer-edition

#### Package Managers
brew install mise

brew install git gh
echo "alias gs='git status' gc='git checkout' ga='git add' gsl='git stash list' gss='git stash save' gm='git commit -m' gd='git diff'" >> ~/.zshrc

brew install --cask dbeaver-community

#### IDEs and Editors
brew install --cask visual-studio-code
xargs -n 1 code --install-extension < vscode-extensions.txt
brew install --cask cursor windsurf zed

#### Utilities
brew install jq tree libevent telnet ripgrep wget glow
## brew install authy
# brew install wireshark wireshark-chmodbpf
# brew install proxyman

#### Infra
brew install --cask podman-desktop
brew install docker
brew install --cask docker-desktop
# brew install vagrant vagrant-manager
# brew install virtualbox

#### Cloud
brew install gcloud-cli
# brew install awscli
# curl -Lo /usr/local/bin/ecs-cli https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-darwin-amd64-latest
# chmod +x /usr/local/bin/ecs-cli
# brew install azure-cli
# brew install gcloud-cli
# brew install terraform
# brew install kreuzwerker/taps/m1-terraform-provider-helper
# m1-terraform-provider-helper activate
# m1-terraform-provider-helper install hashicorp/template -v v2.2.0

#### Kubernetes
# brew install minikube
brew install kubernetes-cli kubectx helm kind
brew install --cask openlens

#### Apps
# brew install zotero
brew install --cask spotify
brew install --cask dropbox
brew install --cask notion
brew install --cask postman
# brew install drawio
brew install --cask logseq
# Parallel agents https://emdash.sh/
brew install --cask emdash

#### Formal Methods
# brew install tla-plus-toolbox
# brew install alloy

#### Languages and Frameworks
# brew install prest
# brew install maven
# brew install elixir
brew install gh
mise use -g go@latest python@latest uv@latest bun@latest node@latest java@temurin-21
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
# brew install leiningen
# brew install adoptopenjdk8 # brew install --cask temurin8
# jenv add /Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home/
# brew install --cask graalvm/tap/graalvm-ce-java11
# xattr -r -d com.apple.quarantine /Library/Java/JavaVirtualMachines/graalvm-ce-java11-21.0.0
# jenv add /Library/Java/JavaVirtualMachines/graalvm-ce-java11-21.0.0/Contents/Home
brew install --cask claude chatgpt codex-app
brew install claude-code codex gemini-cli opencode pi-coding-agent
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
# curl -fsSL https://ampcode.com/install.sh | zsh  # not currently installed
# https://littlebird.ai/how-to-install

#### Databases
brew install postgresql@14 redis

#### Terminals
brew install --cask ghostty

#### Browsers
brew install --cask google-chrome

#### Utilities
# brew install libpq
# brew install pre-commit
# brew install cairo pango
# brew install difftastic
# Repo health https://repohealth.tools/
# go install github.com/spbuilds/repohealth/cmd/repohealth@latest

#### Communication
brew install --cask zoom slack discord

#### Media
brew install yt-dlp

#### Build Tools
brew install go-task

#### References:
# https://medium.com/@maxy_ermayank/developer-environment-setup-script-5fcb7b854acc

#### Themes : Solarizer : https://ethanschoonover.com/solarized/
# curl https://ethanschoonover.com/solarized/files/solarized.zip -o solarized.zip
# unzip solarized.zip -d ~/.solarized

#### TODO
#### IntelliJ plugins
# wget -qO-  https://plugins.jetbrains.com/files/$(curl https://plugins.jetbrains.com/api/plugins/4415/updates | jq -r '.[0].file') | bsdtar -xvf- -C ~/.PhpStorm2018.3/config/plugins

#### Interesting projects
##### Glamorous Toolkit
# curl https://dl.feenk.com/scripts/mac.sh | bash
