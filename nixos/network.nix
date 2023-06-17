{ config, lib, pkgs, ... }:
let
  publicDnsServer = "8.8.8.8";
in
{
  boot = {
    kernel = {
      sysctl = {
        "net.ipv4.conf.all.forwarding" = true;
        "net.ipv6.conf.all.forwarding" = true;
      };
    };
  };
  networking = {
    useNetworkd = true;
    useDHCP = false;
    # hostName = "bpir3";

    # No local firewall.
    firewall.enable = false;
  };

  systemd.network = {
    wait-online.anyInterface = true;
    netdevs = {
      # Create the bridge interface
      "20-br0" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "br0";
        };
      };
    };
    networks = {
      # Connect the bridge ports to the bridge
      "30-lan1" = {
        matchConfig.Name = "lan1";
        networkConfig = {
          Bridge = "br0";
          ConfigureWithoutCarrier = true;
        };
        linkConfig.RequiredForOnline = "enslaved";
      };
      "30-lan2" = {
        matchConfig.Name = "lan2";
        networkConfig = {
          Bridge = "br0";
          ConfigureWithoutCarrier = true;
        };
        linkConfig.RequiredForOnline = "enslaved";
      };
      "30-lan3" = {
        matchConfig.Name = "lan3";
        networkConfig = {
          Bridge = "br0";
          ConfigureWithoutCarrier = true;
        };
        linkConfig.RequiredForOnline = "enslaved";
      };
      "30-lan4" = {
        matchConfig.Name = "lan4";
        networkConfig = {
          Bridge = "br0";
          ConfigureWithoutCarrier = true;
        };
        linkConfig.RequiredForOnline = "enslaved";
      };
      # # Configure the bridge for its desired function
      "40-br0" = {
        matchConfig.Name = "br0";
        bridgeConfig = { };
        linkConfig = {
          # or "routable" with IP addresses configured
          # RequiredForOnline = "carrier";
        };
      };
      "10-wan" = {
        matchConfig.Name = "wan";
        networkConfig = {
          # start a DHCP Client for IPv4 Addressing/Routing
          DHCP = "ipv4";
          # accept Router Advertisements for Stateless IPv6 Autoconfiguraton (SLAAC)
          IPv6AcceptRA = true;
        };
        # make routing on this interface a dependency for network-online.target
        linkConfig.RequiredForOnline = "routable";
      };
    };

  };

  #
  # wireless access point
  services.hostapd = {
    enable = true;
    radios = {
      wlan0 = {
        hwMode = "g";
        countryCode = "PL";
        networks = {
          wlan0 = {
            ssid = "koteczkowo4";
            authentication = {
              mode = "wpa3-sae";
              saePasswords = [{ password = "replication"; }];
            };
            bssid = "e6:00:43:07:00:00";
          };
          wlan0-1 = {
            ssid = "koteczkowo3";
            authentication = {
              mode = "wpa3-sae-transition";
              saePasswords = [{ password = "replication"; }];
              wpaPassword = "replication";
            };
            bssid = "e6:02:43:07:00:00";
          };
        };
      };
      wlan1 = {
        hwMode = "a";
        channel = 132; # Enable automatic channel selection (ACS). Use only if your hardware supports it.
        countryCode = "PL";
        networks = {
          wlan1 = {
            ssid = "koteczkowo4";
            authentication.saePasswords = [{ password = "replication"; }]; # Use saePasswordsFile if possible.
            bssid = "e6:d0:43:07:00:00";
          };
        };
      };
    };
  };


  # The service irqbalance is useful as it assigns certain IRQ calls to specific CPUs instead of letting the first CPU core to handle everything. This is supposed to increase performance by hitting CPU cache more often.
  services.irqbalance.enable = true;

  # services.create_ap = {
  #   enable = true;
  #   settings = {
  #     INTERNET_IFACE = "wan";
  #     WIFI_IFACE = "wlan0";
  #     SSID = "My Wifi Hotspot";
  #     PASSPHRASE = "12345678";
  #   };
  # };

}
