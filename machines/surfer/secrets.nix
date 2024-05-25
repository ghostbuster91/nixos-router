{ username, ... }: {
  # This will add secrets.yml to the nix store
  # You can avoid this by adding a string to the full path instead, i.e.
  # This will automatiycally import SSH keys as age keys
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age.sshKeyPaths = [ "/home/${username}/.ssh/id_ed25519" ];
  sops.age.generateKey = false;
  # This is the actual specification of the secrets.
  sops.secrets.wifiPassword = { };
  sops.secrets.legacyWifiPassword = { };
  sops.secrets.legacyWifiPassword2 = { };
}
