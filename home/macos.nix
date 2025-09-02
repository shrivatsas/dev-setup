{ config, pkgs, lib, ... }:
{
  home.packages =
    (with pkgs; [
      # Terminals and shell utils (WezTerm configured via HM module)
      # GNU userland for macOS for cross-OS consistency
      coreutils
      gnugrep
      gnused
      findutils
      gawk
      gnutar

      # Databases and tools
      dbeaver
    ]);
}
