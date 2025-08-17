{ self
, ...
}: {
  perSystem = { pkgs, lib, system, ... }:
    let
      # Only check the configurations for the current system
      sysConfigs = lib.filterAttrs (_name: value: value.pkgs.system == system) self.nixosConfigurations;
    in
    {
      # Add all the nixos configurations to the checks
      checks = lib.mapAttrs' (name: value: { name = "nixos-toplevel-${name}"; value = value.config.system.build.toplevel; }) sysConfigs;


      devshells.default = {
        packages = [
          # inputs.agenix.outputs.packages.${system}.agenix
          pkgs.nix
          pkgs.deploy-rs
        ];
      };
    };
}

