{ ... }:
{
  flake.homeModules = {
    base = ./base.nix;
    nvim = ./nvim;
    git = ./git;
    zsh = ./zsh;
  };

}

