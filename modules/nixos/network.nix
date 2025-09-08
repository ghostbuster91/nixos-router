{
  boot = {
    kernel = {
      sysctl = {
        "net.ipv4.conf.all.forwarding" = true;
        "net.ipv6.conf.all.forwarding" = true;
        "net.ipv4.conf.br-lan.rp_filter" = 1;
      };
    };
  };
  networking = {
    hostName = "surfer";
    useNetworkd = true;
    useDHCP = false;

    # No local firewall.
    nat.enable = false;
    firewall.enable = true;

    nameservers = [ "8.8.8.8" "1.1.1.1" ];

    nftables = {
      enable = false;
      checkRuleset = false;
      ruleset = '''';
    };
  };

  systemd.network = {
    wait-online.anyInterface = true;
    netdevs = {
      # Create the bridge interface
      "20-br-lan" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "br-lan";
        };
      };
    };
    networks = {
      # Connect the bridge ports to the bridge
      "30-lan0" = {
        matchConfig.Name = "lan0";
        networkConfig = {
          Bridge = "br-lan";
          ConfigureWithoutCarrier = true;
        };
        linkConfig.RequiredForOnline = "enslaved";
      };
      "30-lan1" = {
        matchConfig.Name = "lan1";
        networkConfig = {
          Bridge = "br-lan";
          ConfigureWithoutCarrier = true;
        };
        linkConfig.RequiredForOnline = "enslaved";
      };
      "30-lan2" = {
        matchConfig.Name = "lan2";
        networkConfig = {
          Bridge = "br-lan";
          ConfigureWithoutCarrier = true;
        };
        linkConfig.RequiredForOnline = "enslaved";
      };
      "30-lan3" = {
        matchConfig.Name = "lan3";
        networkConfig = {
          Bridge = "br-lan";
          ConfigureWithoutCarrier = true;
        };
        linkConfig.RequiredForOnline = "enslaved";
      };
      # Configure the bridge for its desired function
      "40-br-lan" = {
        matchConfig.Name = "br-lan";
        bridgeConfig = { };
        networkConfig = {
          MulticastDNS = true;
          ConfigureWithoutCarrier = true;
          # start a DHCP Client for IPv4 Addressing/Routing
          DHCP = "ipv4";
          # accept Router Advertisements for Stateless IPv6 Autoconfiguraton (SLAAC)
          IPv6AcceptRA = true;
          DNSOverTLS = false;
          DNSSEC = false;
          IPv6PrivacyExtensions = false;
        };
        # Don't wait for it as it also would wait for wlan and DFS which takes around 5 min 
        linkConfig.RequiredForOnline = "no";
      };
      "10-wan" = {
        matchConfig.Name = "wan";
        networkConfig = {
          Bridge = "br-lan";
          ConfigureWithoutCarrier = true;
        };
        linkConfig.RequiredForOnline = "enslaved";
      };
    };
  };

  services.resolved = {
    enable = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      userServices = true;
      domain = true;
    };
  };

  services.tailscale.enable = true;
}
