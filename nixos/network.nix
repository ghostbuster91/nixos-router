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
    hostName = "surfer";
    nameservers = [ "${publicDnsServer}" ];
    useNetworkd = true;
    useDHCP = false;

    # No local firewall.
    nat.enable = false;
    firewall.enable = false;
    nftables = {
      enable = true;
      ruleset = ''
        table ip filter {
          chain input {
            type filter hook input priority 0; policy drop;

            iifname { "br0" } accept comment "Allow local network to access the router"
            iifname "wan" ct state { established, related } accept comment "Allow established traffic"
            iifname "wan" icmp type { echo-request, destination-unreachable, time-exceeded } counter accept comment "Allow select ICMP"
            iifname "wan" counter drop comment "Drop all other unsolicited traffic from wan"
            iifname "lo" accept comment "Accept everything from loopback interface"
          }
          chain forward {
            type filter hook forward priority filter; policy drop;
            iifname { "br0" } oifname { "wan" } accept comment "Allow trusted LAN to WAN"
            iifname { "wan" } oifname { "br0" } ct state established, related accept comment "Allow established back to LANs"
          }
        }
        
        table ip nat {
          chain postrouting {
            type nat hook postrouting priority 100; policy accept;
            oifname "wan" masquerade
          } 
        }
      '';
    };


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
        address = [
          "192.168.10.1/24"
        ];
        networkConfig = { };
      };
      "10-wan" = {
        matchConfig.Name = "wan";
        networkConfig = {
          # start a DHCP Client for IPv4 Addressing/Routing
          DHCP = "ipv4";
          # accept Router Advertisements for Stateless IPv6 Autoconfiguraton (SLAAC)
          IPv6AcceptRA = true;
          DNSOverTLS = true;
          DNSSEC = true;
          IPv6PrivacyExtensions = false;
          IPForward = true;
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
              saePasswordsFile = config.sops.secrets.wifiPassword.path;
            };
            bssid = "e6:00:43:07:00:00";
            settings = {
              bridge = "br0";
            };
          };
          wlan0-1 = {
            ssid = "koteczkowo3";
            authentication = {
              mode = "wpa3-sae-transition";
              saePasswordsFile = config.sops.secrets.wifiPassword.path;
              wpaPasswordFile = config.sops.secrets.wifiPassword.path;
            };
            bssid = "e6:02:43:07:00:00";
            settings = {
              bridge = "br0";
            };
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
            authentication.saePasswordsFile = config.sops.secrets.wifiPassword.path; # Use saePasswordsFile if possible.
            bssid = "e6:d0:43:07:00:00";
            settings = {
              bridge = "br0";
            };
          };
        };
      };
    };
  };

  services.dnsmasq = {
    enable = true;
    settings = {
      server = [ "9.9.9.9" "8.8.8.8" "1.1.1.1" ];
      domain-needed = true;
      dhcp-range = [ "192.168.10.100,192.168.10.254" ];
      interface = "br0";
      dhcp-host = "192.168.10.1";
    };
  };

  # The service irqbalance is useful as it assigns certain IRQ calls to specific CPUs instead of letting the first CPU core to handle everything. This is supposed to increase performance by hitting CPU cache more often.
  services.irqbalance.enable = true;
}
