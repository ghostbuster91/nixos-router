{
  flake.nixosModules = {
    nixbuild = ./nixbuild.nix;
    hostapd = ./hostapd.nix;
    monitoring = ./monitoring.nix;
    network = ./network.nix;
    sshd = ./sshd.nix;
    nix = ./nix.nix;
  };

}
