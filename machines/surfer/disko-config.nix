{ disks ? [ "/dev/vdb" ], ... }: {
  disko.devices = {
    disk = {
      nvme0n1 = {
        device = builtins.elemAt disks 0;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            "var-log" = {
              priority = 1;
              size = "20G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/var/log";
              };
            };
            "tmp" = {
              priority = 2;
              size = "40G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/tmp";
              };
            };
            "var" = {
              priority = 3;
              size = "40G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/var";
              };
            };
            # "swap" = {
            #   start = "100G";
            #   end = "100%";
            #   content = {
            #     type = "swap";
            #     randomEncryption = false;
            #   };
            # };
          };
        };
      };
    };
  };
}
