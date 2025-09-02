{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    # X clipboard utils
    xclip
  ];
}
