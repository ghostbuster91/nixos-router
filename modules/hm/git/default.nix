{ pkgs, ... }: {

  programs.git = {
    enable = true;
    userName = "ghostbuster91";
    userEmail = "ghostbuster91@users.noreply.github.com";
    extraConfig = {
      merge = { conflictStyle = "diff3"; };
      core = {
        editor = "nvim";
        pager = "${pkgs.diff-so-fancy}/bin/diff-so-fancy | less -FXRi";
      };
      color = { ui = true; };
      push = { default = "simple"; autoSetupRemote = true; };
      pull = { ff = "only"; };
      init = { defaultBranch = "main"; };
      submodule = { recurse = true; };
      user = {
        signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFFeU4GXH+Ae00DipGGJN7uSqPJxWFmgRo9B+xjV3mK4";
      };
      gpg.format = "ssh";
      gpg.ssh = { allowedSignersFile = "~/.ssh/allowed_signers"; };
      commit.gpgsign = true;
    };
  };

  home.file."./.ssh/allowed_signers".text = ''
    ghostbuster91@users.noreply.github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFFeU4GXH+Ae00DipGGJN7uSqPJxWFmgRo9B+xjV3mK4
  '';
}

