let
  kghost = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFFeU4GXH+Ae00DipGGJN7uSqPJxWFmgRo9B+xjV3mK4";
  surfer = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBkM0hU+Zrb1bOaMcwGO1DeM7u/jXIuCS9n7RqPYkYqH";
in
{
  "wifiPassword.age".publicKeys = [ kghost surfer ];
  "legacyWifiPassword.age".publicKeys = [ kghost surfer ];
  "legacyWifiPassword2.age".publicKeys = [ kghost surfer ];
  "wlan00bssid.age".publicKeys = [ kghost surfer ];
  "wlan01bssid.age".publicKeys = [ kghost surfer ];
  "wlan10bssid.age".publicKeys = [ kghost surfer ];
}
