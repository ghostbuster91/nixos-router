{
  services.prometheus = {
    exporters = {
      node = {
        enable = true;
        # TODO test perf impact of these modules
        enabledCollectors = [
          "arp"
          "hwmon"
          "cpu"
          "diskstats"
          "ethtool"
          "interrupts"
          "ksmd"
          "lnstat"
          "mountstats"
          "processes"
          "systemd"
          "wifi"
          "tcpstat"
          "netdev"
          "netstat"
          "network_route"
          "netclass"
          "sockstat"
          "stat"
          "conntrack"
        ];
        port = 9002;
      };
    };
  };
  services.promtail = {
    enable = true;
    configuration = {
      server = {
        disable = true;
      };
      # positions = {
      #   filename = "/var/log/positions.yaml";
      # };
      clients = [{
        url = "http://loki.local/loki/api/v1/push";
      }];
      scrape_configs = [{
        job_name = "journal";
        journal = {
          max_age = "12h";
          labels = {
            job = "systemd-journal";
            host = "surfer";
          };
        };
        relabel_configs = [{
          source_labels = [ "__journal__systemd_unit" ];
          target_label = "unit";
        }];
      }];
    };
  };
}
