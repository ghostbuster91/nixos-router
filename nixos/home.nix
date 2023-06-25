{ pkgs, config, inputs, lib, username, ... }: {

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "22.05";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  imports = [
    ./programs/nvim
    ./programs/git
    ./programs/zsh
  ];

  home.packages = with pkgs; [
    nix-tree
    ripgrep
    fd # faster find
  ];

  programs = {
    exa = {
      enable = true;
      enableAliases = true;
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      stdlib = ''
        unset LD_LIBRARY_PATH
      '';
    };
    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
    ssh = {
      enable = true;
    };
  };
}
