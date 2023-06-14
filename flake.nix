{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    ghostbuster = {
      url = "github:ghostbuster91/dot-files";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , ...
    }@attrs:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      username = "kghost";
    in
    {
      formatter = forAllSystems (system:
        nixpkgs.legacyPackages.${system}.nixpkgs-fmt
      );

      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        (import ./pkgs { inherit pkgs; }) // pkgs
      );

      nixosModules = import ./modules;

      nixosConfigurations = {
        bpir3 = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            inherit self;
            inherit (self.packages.aarch64-linux) armTrustedFirmwareMT7986;
            inherit username;
          };
          modules = [
            ./lib/sd-image-mt7986.nix
            ./nixos/hardware-configuration.nix
            ./nixos/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useUserPackages = true;
                useGlobalPkgs = true;
                users.${username} = ./nixos/home.nix;
                extraSpecialArgs = { inherit username; };
              };
            }
            # flake registry
            {
              nix.registry.nixpkgs.flake = inputs.nixpkgs;
            }
          ];
        };
      };
    };
}
