{ self, inputs, lib, ... }:
let
  username = "kghost";
  system = "aarch64-linux";
in
{
  flake.nixosConfigurations = {
    surfer =
      lib.nixosSystem {
        modules = [ ./surfer ];
        specialArgs = {
          inherit username;
          inherit inputs;
        };
      };
  };

  flake.deploy = {
    nodes = {
      surfer = {
        sshUser = "kghost";
        hostname = "surfer.local";
        user = "root";
        remoteBuild = false;
        sshOpts = [ "-oControlMaster=no" ];
        profiles.system.path =
          inputs.deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.surfer;
      };
    };

  };

  perSystem = { pkgs, lib, system, ... }:
    let
      # Only check the configurations for the current system
      sysConfigs = lib.filterAttrs (_name: value: value.pkgs.system == system) self.nixosConfigurations;
      deployRsChecks = (builtins.mapAttrs (_system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib).${system};
    in
    {
      # Add all the nixos configurations to the checks
      checks = (lib.mapAttrs' (name: value: { name = "nixos-toplevel-${name}"; value = value.config.system.build.toplevel; }) sysConfigs) // deployRsChecks;
    };
}
