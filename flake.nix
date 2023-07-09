{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hostapd.url = "github:oddlama/nixpkgs";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    bpir3 = {
      url = "github:nakato/nixos-bpir3-example";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-nftables-firewall = {
      url = "github:thelegy/nixos-nftables-firewall";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , hostapd
    , disko
    , sops-nix
    , bpir3
    , nixos-nftables-firewall
    , ...
    }@attrs:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      username = "kghost";
      hostapdPackages = forAllSystems (system:
        let
          pkgs = hostapd.legacyPackages.${system};
        in
        pkgs
      );
    in
    {
      formatter = forAllSystems (system:
        nixpkgs.legacyPackages.${system}.nixpkgs-fmt
      );

      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        bpir3.packages.${system} // pkgs
      );

      nixosModules = import ./modules;

      nixosConfigurations = {
        surfer = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            inherit self;
            inherit (self.packages.aarch64-linux) armTrustedFirmwareMT7986;
            inherit username;
            inherit hostapd;
            inherit hostapdPackages;
            inherit bpir3;
          };
          modules = [
            "${bpir3}/lib/sd-image-mt7986.nix"
            ./nixos/hardware-configuration.nix
            ./nixos/configuration.nix
            home-manager.nixosModules.home-manager
            disko.nixosModules.disko
            # sops-nix.nixosModules.sops
            nixos-nftables-firewall.nixosModules.default
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
              nix.registry.nixpkgs.flake = nixpkgs;
            }
          ];
        };
      };
    };
}
