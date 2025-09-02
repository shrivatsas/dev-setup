{ config, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -lah";
      gs = "git status";
      gc = "git checkout";
      ga = "git add";
      gsl = "git stash list";
      gss = "git stash save";
      gm = "git commit -m";
      gd = "git diff";
      k = "kubectl";
    };
    initExtra = ''
      eval "$(direnv hook zsh)"
      eval "$(starship init zsh)"
    '';
  };
}
