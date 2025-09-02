{ config, pkgs, ... }:
{
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.zsh.enable = true;

  system.defaults.dock.autohide = true;
  system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;

  networking.hostName = "YOUR_HOSTNAME";
  system.autoUpgrade.enable = false;
  system.stateVersion = 4;
}