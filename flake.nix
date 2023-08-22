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
    nixos-nftables-firewall = {
      url = "github:thelegy/nixos-nftables-firewall";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
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

      nixosConfigurations =
        let
          createSystem = modules: kernelPackages: nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            specialArgs = {
              inherit self;
              inherit (self.packages.aarch64-linux) armTrustedFirmwareMT7986;
              inherit username;
              inherit kernelPackages;
              inherit bpir3;
            };
            modules = [
              home-manager.nixosModules.home-manager
              disko.nixosModules.disko
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
            ] ++ modules;
          };
        in
        {
          surfer =
            let
              modules = [
                ./nixos/hardware-configuration.nix
                ./nixos/configuration.nix
                ./nixos/hostapd.nix
                ./nixos/sops.nix
                sops-nix.nixosModules.sops
                "${bpir3}/lib/sd-image-mt7986.nix"
              ];
            in
            createSystem modules bpir3.packages.aarch64-linux.linuxPackages_bpir3;
          # By default there is no swap and bpir3 doesn't have enough RAM to compile full kernel
          # Besides that, the default image does not contain key to decrypt sops-nix secrets which is needed for the wifi to start 
          # Without wlan interfaces the br-lan intreface is unable to come-up online which prevents logging into the device. 
          bootstrap =
            let
              modules = [
                ./nixos/hardware-configuration.nix
                ./nixos/configuration.nix
                "${bpir3}/lib/sd-image-mt7986.nix"
              ];
            in
            createSystem modules bpir3.packages.aarch64-linux.linuxPackages_bpir3_minimal;
        };
    };
}
