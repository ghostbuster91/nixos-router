{ inputs, ... }:
{
  flake.nixosModules = {
    nixbuild = ./nixbuild.nix;
    hostapd = ./hostapd.nix;
    monitoring = ./monitoring.nix;
    network = ./network.nix;
    sshd = ./sshd.nix;
    nix = ./nix.nix;
    sd-image-mt7986 = "${inputs.bpir3}/lib/sd-image-mt7986.nix";
  };

}
