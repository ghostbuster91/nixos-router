{ config, lib, pkgs, ... }:
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
    useNetworkd = true;
    useDHCP = false;

    # No local firewall.
    nat.enable = false;
    firewall.enable = false;

    # Use the nftables firewall instead of the base nixos scripted rules.
    # This flake provides a similar utility to the base nixos scripting.
    # https://github.com/thelegy/nixos-nftables-firewall/tree/main
    nftables = {
      enable = true;
      stopRuleset = "";
      firewall = {
        enable = true;
        zones = {
          lan.interfaces = [ "br-lan" ];
          wan.interfaces = [ "wan" ];
        };
        rules = {
          lan = {
            from = [ "lan" ];
            to = [ "fw" ];
            verdict = "accept";
          };
          outbound = {
            from = [ "lan" ];
            to = [ "lan" "wan" ];
            verdict = "accept";
          };
          nat = {
            from = [ "lan" ];
            to = [ "wan" ];
            masquerade = true;
          };
        };
      };
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
        };
        linkConfig.RequiredForOnline = "enslaved";
      };
      "30-lan1" = {
        matchConfig.Name = "lan1";
        networkConfig = {
          Bridge = "br-lan";
        };
        linkConfig.RequiredForOnline = "enslaved";
      };
      "30-lan2" = {
        matchConfig.Name = "lan2";
        networkConfig = {
          Bridge = "br-lan";
        };
        linkConfig.RequiredForOnline = "enslaved";
      };
      "30-lan3" = {
        matchConfig.Name = "lan3";
        networkConfig = {
          Bridge = "br-lan";
        };
        linkConfig.RequiredForOnline = "enslaved";
      };
      # Configure the bridge for its desired function
      "40-br-lan" = {
        matchConfig.Name = "br-lan";
        bridgeConfig = { };
        address = [
          "192.168.10.1/24"
        ];
        networkConfig = { 
          ConfigureWithoutCarrier = true;
        };
        # Don't wait for it as it also would wait for wlan and DFS which takes around 5 min 
        linkConfig.RequiredForOnline = "no";
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

  # wireless access point
  services.hostapd = {
    enable = true;
    radios = {
      wlan0 = {
        band = "2g";
        countryCode = "PL";
        channel = 0; # ACS

        # use 'iw phy#1 info' to determine your VHT capabilities
        wifi4 = {
          enable = true;
          capabilities = [ "HT40+" "LDPC" "SHORT-GI-20" "SHORT-GI-40" "TX-STBC" "RX-STBC1" "MAX-AMSDU-7935" ];
        };
        networks = {
          wlan0 = {
            ssid = "koteczkowo5";
            authentication = {
              mode = "wpa3-sae";
              saePasswordsFile = config.sops.secrets.wifiPassword.path;
            };
            bssid = "36:b9:02:21:08:00";
            settings = {
              bridge = "br-lan";
            };
          };
          # Uncomment when needed otherwise remove
          wlan0-1 = {
            ssid = "koteczkowo3";
            authentication = {
              mode = "none"; # this is overriden by settings
            };
            managementFrameProtection = "optional";
            bssid = "e6:02:43:07:00:00";
            settings = {
              bridge = "br-lan";
              wpa = lib.mkForce 2;
              wpa_key_mgmt = "WPA-PSK";
              wpa_pairwise = "CCMP";
              wpa_passphrase = config.sops.secrets.legacyWifiPassword.path;
            };
          };
        };
      };
      wlan1 = {
        band = "5g";
        # channels with 160 MHz width in Poland: 36, 52, 100 i 116
        channel = 0; # ACS
        countryCode = "PL";

        # use 'iw phy#1 info' to determine your VHT capabilities
        wifi4 = {
          enable = true;
          capabilities = [ "HT40+" "LDPC" "SHORT-GI-20" "SHORT-GI-40" "TX-STBC" "RX-STBC1" "MAX-AMSDU-7935" ];
        };
        wifi5 = {
          enable = true;
          operatingChannelWidth = "160";
          capabilities = [ "RXLDPC" "SHORT-GI-80" "SHORT-GI-160" "TX-STBC-2BY1" "SU-BEAMFORMER" "SU-BEAMFORMEE" "MU-BEAMFORMER" "MU-BEAMFORMEE" "RX-ANTENNA-PATTERN" "TX-ANTENNA-PATTERN" "RX-STBC-1" "SOUNDING-DIMENSION-4" "BF-ANTENNA-4" "VHT160" "MAX-MPDU-11454" "MAX-A-MPDU-LEN-EXP7" ];
        };
        wifi6 = {
          enable = true;
          singleUserBeamformer = true;
          singleUserBeamformee = true;
          multiUserBeamformer = true;
          operatingChannelWidth = "160";
        };
        settings = {
          # these two are mandatory for wifi 5 & 6 to work
          vht_oper_centr_freq_seg0_idx = 50;
          he_oper_centr_freq_seg0_idx = 50;

          # The "tx_queue_data2_burst" parameter in Linux refers to the burst size for 
          # transmitting data packets from the second data queue of a network interface. 
          # It determines the number of packets that can be sent in a burst. 
          # Adjusting this parameter can impact network throughput and latency.
          tx_queue_data2_burst = 2;


          # The "he_bss_color" parameter in Wi-Fi 6 (802.11ax) refers to the BSS Color field in the HE (High Efficiency) MAC header.
          # BSS Color is a mechanism introduced in Wi-Fi 6 to mitigate interference and improve network efficiency in dense deployment scenarios. 
          # It allows multiple overlapping Basic Service Sets (BSS) to differentiate and coexist in the same area without causing excessive interference.
          he_bss_color = 63; # was set to 128 by openwrt but range of possible values in 2.10 is 1-63

          # Magic values that were set by openwrt but I didn't bother inspecting every single one
          he_spr_sr_control = 3;
          he_default_pe_duration = 4;
          he_rts_threshold = 1023;

          he_mu_edca_qos_info_param_count = 0;
          he_mu_edca_qos_info_q_ack = 0;
          he_mu_edca_qos_info_queue_request = 0;
          he_mu_edca_qos_info_txop_request = 0;

          # he_mu_edca_ac_be_aci=0; missing in 2.10
          he_mu_edca_ac_be_aifsn = 8;
          he_mu_edca_ac_be_ecwmin = 9;
          he_mu_edca_ac_be_ecwmax = 10;
          he_mu_edca_ac_be_timer = 255;

          he_mu_edca_ac_bk_aifsn = 15;
          he_mu_edca_ac_bk_aci = 1;
          he_mu_edca_ac_bk_ecwmin = 9;
          he_mu_edca_ac_bk_ecwmax = 10;
          he_mu_edca_ac_bk_timer = 255;

          he_mu_edca_ac_vi_ecwmin = 5;
          he_mu_edca_ac_vi_ecwmax = 7;
          he_mu_edca_ac_vi_aifsn = 5;
          he_mu_edca_ac_vi_aci = 2;
          he_mu_edca_ac_vi_timer = 255;

          he_mu_edca_ac_vo_aifsn = 5;
          he_mu_edca_ac_vo_aci = 3;
          he_mu_edca_ac_vo_ecwmin = 5;
          he_mu_edca_ac_vo_ecwmax = 7;
          he_mu_edca_ac_vo_timer = 255;
        };
        networks = {
          wlan1 = {
            ssid = "koteczkowo5";
            authentication = {

              mode = "wpa3-sae";
              saePasswordsFile = config.sops.secrets.wifiPassword.path; # Use saePasswordsFile if possible.
            };
            bssid = "36:b9:02:21:08:a2";
            settings = {
              bridge = "br-lan";
            };
          };
        };
      };
    };
  };

  services.resolved.enable = false;

  services.dnsmasq = {
    enable = true;
    settings = {
      # upstream DNS servers
      server = [ "9.9.9.9" "8.8.8.8" "1.1.1.1" ];
      # sensible behaviours
      domain-needed = true;
      bogus-priv = true;
      no-resolv = true;

      dhcp-range = [ "192.168.10.100,192.168.10.254" ];
      interface = "br-lan";
      dhcp-host = "192.168.10.1";

      # local domains
      local = "/lan/";
      domain = "lan";
      expand-hosts = true;

      # don't use /etc/hosts as this would advertise surfer as localhost
      no-hosts = true;
      address = "/surfer.lan/192.168.10.1";
    };
  };

  # The service irqbalance is useful as it assigns certain IRQ calls to specific CPUs instead of letting the first CPU core to handle everything. This is supposed to increase performance by hitting CPU cache more often.
  services.irqbalance.enable = true;
}
