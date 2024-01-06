{ self, inputs, lib, ... }:
let
  username = "kghost";
in
{
  flake.nixosConfigurations = {
    surfer =
      lib.nixosSystem {
        modules = [ ./surfer ];
        specialArgs = {
          inherit inputs; inherit username;
          # needed internally by build sdcard image
          inherit (inputs.bpir3.packages.aarch64-linux) armTrustedFirmwareMT7986;
        };
      };
  };

  perSystem = { pkgs, lib, system, ... }:
    let
      # Only check the configurations for the current system
      sysConfigs = lib.filterAttrs (_name: value: value.pkgs.system == system) self.nixosConfigurations;
    in
    {
      # Add all the nixos configurations to the checks
      checks = lib.mapAttrs' (name: value: { name = "nixos-toplevel-${name}"; value = value.config.system.build.toplevel; }) sysConfigs;
    };
}
