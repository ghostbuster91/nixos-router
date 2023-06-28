{ lib, pkgs, hostapd, username, ... }: {
  # This will add secrets.yml to the nix store
  # You can avoid this by adding a string to the full path instead, i.e.
  # This will automatiycally import SSH keys as age keys
  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.age.sshKeyPaths = [ "/home/${username}/.ssh/id_ed25519" ];
  sops.age.generateKey = false;
  # The mainWifiPasswords secret contains entries in the following format:
  # $password|vlan_id=$id
  sops.secrets.mainWifiPasswords = { };
  # The iotWifiPassword secret contains entries in the following format:
  # vlan_id=$id $mac_address $password
  sops.secrets.iotWifiPasswords = { };
}
