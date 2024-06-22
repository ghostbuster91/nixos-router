{ pkgs, username, ... }: {

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "24.05";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.packages = with pkgs; [
    nix-tree
    ripgrep
    fd # faster find
  ];

  programs = {
    exa = {
      enable = true;
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
      extraConfig = ''
        Host rpi5
          IdentitiesOnly yes
          IdentityFile /home/kghost/.ssh/nixremote
          User nixremote
      '';
    };
  };
}
