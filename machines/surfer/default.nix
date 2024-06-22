{ inputs, username, ... }:
{
  nixpkgs.hostPlatform = "aarch64-linux";

  imports =
    [
      # inputs.disko.nixosModules.default
      # (import ./disko-config.nix {
      #   disks = [ "/dev/nvme0n1" ];
      # })
      inputs.sops.nixosModules.default
      ./secrets.nix
      inputs.self.nixosModules.nix
      inputs.self.nixosModules.nixbuild
      ./custom.nix
      inputs.self.nixosModules.sshd
      inputs.self.nixosModules.monitoring
      inputs.self.nixosModules.network
      inputs.self.nixosModules.rpi-builder
      # inputs.self.nixosModules.hostapd
      inputs.home-manager.nixosModule

      inputs.nixos-sbc.nixosModules.default
      inputs.nixos-sbc.nixosModules.boards.bananapi.bpir3
      {
        sbc = {
          version = "0.2";
          bootstrap.rootFilesystem = "ext4";
          wireless.wifi.acceptRegulatoryResponsibility = true;
        };
      }
    ];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users.${username} = {
      imports = [
        inputs.self.homeModules.base
        inputs.self.homeModules.nvim
        inputs.self.homeModules.zsh
        inputs.self.homeModules.git
        inputs.nix-index-database.hmModules.nix-index
      ];
    };
    extraSpecialArgs = { inherit username; };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It’s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
