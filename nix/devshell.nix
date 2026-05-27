{ ... }: {
  perSystem = { pkgs, ... }: {
    devshells.default = {
      packages = [
        pkgs.nix
        pkgs.deploy-rs
      ];
    };
  };
}

