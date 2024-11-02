{ username, ... }: {
  sops = {
    # This will add secrets.yml to the nix store
    # You can avoid this by adding a string to the full path instead, i.e.
    # This will automatiycally import SSH keys as age keys
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.sshKeyPaths = [ "/home/${username}/.ssh/id_ed25519" ];
    age.generateKey = false;
    secrets = {
      # This is the actual specification of the secrets.
      wifiPassword = { };
      legacyWifiPassword = { };
      legacyWifiPassword2 = { };
      wlan00bssid = { };
      wlan01bssid = { };
      wlan10bssid = { };
    };
  };
}
