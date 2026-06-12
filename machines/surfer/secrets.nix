{ username, ... }: {
  sops = {
    # This will add secrets.yml to the nix store
    # You can avoid this by adding a string to the full path instead, i.e.
    # This will automatiycally import SSH keys as age keys
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.sshKeyPaths = [ "/home/${username}/.ssh/id_ed25519" ];
    age.generateKey = false;
    secrets =
      let
        hostapd = { restartUnits = [ "hostapd.service" ]; };
      in
      {
        # This is the actual specification of the secrets.
        wifiPassword = hostapd;
        legacyWifiPassword = hostapd;
        legacyWifiPassword2 = hostapd;
        wlan00bssid = hostapd;
        wlan01bssid = hostapd;
        wlan10bssid = hostapd;
      };
  };
}
