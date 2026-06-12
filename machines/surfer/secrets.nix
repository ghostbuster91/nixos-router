{ ... }:
let
  hostapdSecrets = {
    wifiPassword = ../../secrets/wifiPassword.age;
    legacyWifiPassword = ../../secrets/legacyWifiPassword.age;
    legacyWifiPassword2 = ../../secrets/legacyWifiPassword2.age;
    wlan00bssid = ../../secrets/wlan00bssid.age;
    wlan01bssid = ../../secrets/wlan01bssid.age;
    wlan10bssid = ../../secrets/wlan10bssid.age;
  };
in
{
  age = {
    identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets = builtins.mapAttrs (_: file: { inherit file; }) hostapdSecrets;
  };
}
