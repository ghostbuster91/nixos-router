{ inputs, ... }: {
  perSystem = { pkgs, system, ... }: {
    devshells.default = {
      packages = [
        pkgs.nix
        pkgs.deploy-rs
        inputs.agenix.outputs.packages.${system}.agenix
      ];
    };
  };
}

