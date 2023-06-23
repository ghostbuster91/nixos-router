{ pkgs, ... }: {
  services.prometheus = {
    exporters = {
      node = {
        enable = true;
        # TODO test perf impact of these modules
        # enabledCollectors = [ "systemd"  "wifi" "ethtool" ];
        port = 9002;
      };
    };
  };
}
