({ config, lib, kernelPackages, bpir3, ... }: {
  boot.kernelPackages = kernelPackages;
  # We exclude a number of modules included in the default list. A non-insignificant amount do
  # not apply to embedded hardware like this, so simply skip the defaults.
  #
  # Custom kernel is required as a lot of MTK components misbehave when built as modules.
  # They fail to load properly, leaving the system without working ethernet, they'll oops on
  # remove. MTK-DSA parts and PCIe were observed to do this.
  boot.initrd.includeDefaultModules = false;
  boot.initrd.kernelModules = [ "rfkill" "cfg80211" "mt7915e" ];
  boot.initrd.availableKernelModules = [ "nvme" ];

  boot.kernelParams = [ "console=ttyS0,115200" ];
  boot.extraModprobeConfig = ''
    options mt7915e wed_enable=Y
  '';
  hardware.enableRedistributableFirmware = true;
  # Wireless hardware exists, regulatory database is essential.
  hardware.wirelessRegulatoryDatabase = true;

  # Extlinux compatible with custom uboot patches in this repo, which also provide unique
  # MAC addresses instead of the non-unique one that gets used by a lot of MTK devices...
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  # Known to work with u-boot; bz2, lzma, and lz4 should be safe too, need to test.
  boot.initrd.compressor = "gzip";
  hardware.deviceTree.filter = "mt7986a-bananapi-bpi-r3.dtb";

  hardware.deviceTree.overlays = [
    {
      name = "bpir3-sd-enable";
      dtsFile = "${bpir3}/bpir3-dts/mt7986a-bananapi-bpi-r3-sd.dts";
    }
    {
      name = "bpir3-nand-enable";
      dtsFile = "${bpir3}/bpir3-dts/mt7986a-bananapi-bpi-r3-nand.dts";
    }
    {
      name = "bpi-r3 wifi training data";
      dtsFile = "${bpir3}/bpir3-dts/mt7986a-bananapi-bpi-r3-wirless.dts";
    }
    {
      name = "reset button disable";
      dtsFile = "${bpir3}/bpir3-dts/mt7986a-bananapi-bpi-r3-pcie-button.dts";
    }
    {
      name = "mt7986a efuses";
      dtsFile = "${bpir3}/bpir3-dts/mt7986a-efuse-device-tree-node.dts";
    }
  ];

  boot.initrd.preDeviceCommands = ''
    if [ ! -d /sys/bus/pci/devices/0000:01:00.0 ]; then
      if [ -d /sys/bus/pci/devices/0000:00:00.0 ]; then
        # Remove PCI bridge, then rescan.  NVMe init crashes if PCI bridge not removed first
        echo 1 > /sys/bus/pci/devices/0000:00:00.0/remove
        # Rescan brings PCI root back and brings the NVMe device in.
        echo 1 > /sys/bus/pci/rescan
      else
        info "PCIe bridge missing"
      fi
    fi
  '';
})
