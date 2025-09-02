#!/usr/bin/env bash
set -euo pipefail
sh <(curl -L https://nixos.org/nix/install) --daemon
mkdir -p "$HOME/.config/nix"
echo 'experimental-features = nix-command flakes' >> "$HOME/.config/nix/nix.conf"
nix run home-manager/master -- switch --flake .#YOUR_USERNAME