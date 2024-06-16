{ config, lib, ... }:
{
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
          ## working with esp8266 & rpi5
          wlan0-1 = {
            ssid = "koteczkowo3";
            authentication = {
              mode = "none"; # this is overriden by settings
            };
            bssid = "e6:02:43:07:00:00";
            settings = {
              bridge = "br-lan";
              wmm_enabled = false;
              ieee80211w = "0";
              wpa = lib.mkForce 2;
              wpa_key_mgmt = "WPA-PSK";
              wpa_pairwise = "CCMP";
              wpa_psk_file = config.sops.secrets.legacyWifiPassword.path;
              # sae_require_mfp = false;
            };
          };
          # working with rpi5
          # wlan0-1 = {
          #   ssid = "koteczkowo3";
          #   authentication = {
          #     mode = "wpa3-sae-transition"; # this is overriden by settings
          #     wpaPskFile = config.sops.secrets.legacyWifiPassword.path;
          #     saePasswordsFile = config.sops.secrets.legacyWifiPassword2.path;
          #   };
          #   # managementFrameProtection = "optional";
          #   bssid = "e6:02:43:07:00:00";
          #   settings = {
          #     bridge = "br-lan";
          #     ieee80211w = "2";
          #     # sae_require_mfp = false;
          #   };
          # };
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
}
