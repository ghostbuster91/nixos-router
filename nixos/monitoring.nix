{ pkgs, ... }: {
  services.prometheus = {
    exporters = {
      systemd = {
        enable = true;
        port = 9002;
      };
      node = {
        enable = true;
        port = 9002;
      };
    };
  };
}
