{ config, pkgs, lib, ... }:
{
  home.stateVersion = "24.05";

  home.packages =
    (with pkgs; [
      git zsh gh gnupg gnumake unzip zip wget curl
      ripgrep fd fzf jq yq htop btop tree
      starship direnv nix-direnv tmux pre-commit difftastic
      zoxide libevent
      # Networking utilities and packet analysis
      inetutils
      wireshark # Note: on Linux, non-root capture requires system-level perms (e.g., setcap on dumpcap or wireshark group)
      nodejs_20 nodePackages.pnpm
      python312
      unstable.uv
      go
      emacs
      ffmpeg
      elixir
      maven
      leiningen
      postgresql
      google-cloud-sdk
      vault
      gradle
      # attribute name for Task is go-task
      go-task
      # Kotlin toolchain
      kotlin
      # AI CLIs (unconditionally included; verified available)
      codex
      gemini-cli
      amp-cli
      claude-code
      # Productivity / Formal methods / IDEs (verified)
      postman
      alloy6
      tlaplus18
      code-cursor
      windsurf
      # Rust toolchain (stable)
      rustc cargo rustfmt clippy rust-analyzer
      # Haskell toolchain
      ghc cabal-install stack haskell-language-server
      # Java toolchains
      jdk11 jdk17 graalvm-ce
      awscli2 granted
      docker kubectl krew kubectx k9s helm minikube colima terraform
      openssl cmake pkg-config
      jetbrains.idea-community-bin
      # Shared desktop/server apps (verified)
      clickhouse
      mysql84
      redis
      firefox-devedition
      spotify
      slack
      zoom-us
      drawio
      discord
      logseq
    ])

  home.sessionVariables = {
    EDITOR = "nvim";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    PAGER = "less -R";
  };

  fonts.fontconfig.enable = true;
  # Install fonts for WezTerm (and general usage)
  home.packages = (home.packages or []) ++ [
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" "NerdFontsSymbolsOnly" ]; })
    pkgs.noto-fonts-emoji
  ];
}
