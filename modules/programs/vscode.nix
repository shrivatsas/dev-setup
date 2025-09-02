{ config, pkgs, lib, ... }:
let
  # Read extension IDs from the repo file
  rawIds = lib.splitString "\n" (builtins.readFile ./_vscode-extensions.txt);
  ids = lib.filter (s: s != "" && !(lib.hasPrefix "#" s)) rawIds;

  # Convert "publisher.name" -> [ "publisher" "name" ]
  toPath = id: let p = lib.splitString "." id; in if (builtins.length p == 2) then p else null;

  # Resolve an extension id to a nixpkgs derivation, preferring pkgs.vscode-extensions
  resolve = id:
    let p = toPath id; in
    if p == null then builtins.trace ("Skipping invalid VSCode extension id: " + id) null
    else if lib.hasAttrByPath p pkgs.vscode-extensions then lib.attrByPath p null pkgs.vscode-extensions
    else if lib.hasAttrByPath p pkgs.vscode-marketplace then lib.attrByPath p null pkgs.vscode-marketplace
    else builtins.trace ("VSCode extension not found in nixpkgs: " + id) null;

  resolved = lib.filter (x: x != null) (map resolve ids);
in
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode; # unfree, allowed via flake config
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;
    extensions = resolved;
  };
}
