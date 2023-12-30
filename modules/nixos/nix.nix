{ username, pkgs, inputs, ... }: {

  nixpkgs.config = {
    allowUnfree = true;
  };
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" username ];

    };
    package = pkgs.nixVersions.stable;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    registry.nixpkgs.flake = inputs.nixpkgs;
  };
}
