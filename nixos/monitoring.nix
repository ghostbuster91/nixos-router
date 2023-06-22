{ pkgs, ... }: {
  services.prometheus = {
    exporters = {
      node = {
        enable = true;
        systemd.enable = true;
        port = 9002;
      };
    };
  };
}
