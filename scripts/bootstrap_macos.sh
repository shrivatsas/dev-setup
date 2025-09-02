#!/usr/bin/env bash
set -euo pipefail
sh <(curl -L https://nixos.org/nix/install) --daemon
mkdir -p /etc/nix
echo 'experimental-features = nix-command flakes' | sudo tee /etc/nix/nix.conf
nix run nix-darwin -- switch --flake .#YOUR_HOSTNAME