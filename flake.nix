{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    };
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , disko
    , sops-nix
    , bpir3
    , ...
    }@inputs:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      username = "kghost";
      osConfig = system: nixpkgs.lib.nixosSystem
        {
          system = "aarch64-linux";
          specialArgs = {
            inherit self;
            inherit (self.packages.aarch64-linux) armTrustedFirmwareMT7986;
            inherit username;
            inherit bpir3;
            kernelPackages = bpir3.packages.aarch64-linux.linuxPackages_bpir3_minimal;
            inherit inputs;
          };
          modules = [
            ./nixos/hardware-configuration.nix
            ./nixos/configuration.nix
            "${bpir3}/lib/sd-image-mt7986.nix"
            home-manager.nixosModules.home-manager
            disko.nixosModules.disko
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
            { nixpkgs.crossSystem.system = "aarch64-linux"; nixpkgs.system = system; }
          ];
        };
    in
    {
      # packages =
      #   let
      #     pkgs = import nixpkgs {
      #       system = "aarch64-linux";
      #       crossSystem = "aarch64-linux";
      #       buildPlatform.system = "x86_64-linux";
      #       hostPlatform.system = "aarch64-linux";
      #     };
      #   in
      #   pkgs;

      nixosConfigurations.surfer = osConfig "aarch64-linux";
    } // {
      packages.x86_64-linux.image = (osConfig "x86_64-linux").config.system.build.sdImage;
      defaultPackage.x86_64-linux = self.packages.x86_64-linux.image;
    };
}
          
