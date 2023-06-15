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
    nameservers = [ "${publicDnsServer}" ];
    useDHCP = false;
    hostName = "bpir3";
    bridges = {
      br0 = {
        interfaces = [ "lan0" "lan1" "lan2" "lan3" ];
      };
    };
    interfaces = {
      br0 = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "192.168.10.1";
            prefixLength = 24;
          }
        ];
      };
      # wguest = {
      #   useDHCP = false;
      #   ipv4.addresses = [
      #     {
      #       address = "192.168.20.1";
      #       prefixLength = 24;
      #     }
      #   ];
      # };
      wan = {
        useDHCP = true; # Request an IP from the ISP
      };
    };
    wireless.enable = true;

    nat = {
      enable = true;
      internalInterfaces = [
        "br0"
        "wlan0"
        "wlan1"
        # "wguest"
      ];
      externalInterface = "wan";
    };

  };

  # The service irqbalance is useful as it assigns certain IRQ calls to specific CPUs instead of letting the first CPU core to handle everything. This is supposed to increase performance by hitting CPU cache more often.
  services.irqbalance.enable = true;

}
