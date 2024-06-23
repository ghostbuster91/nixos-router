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
              start = "1MiB";
              end = "20G";
              priority = 1;
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/var/log";
              };
            };
            "tmp" = {
              start = "20G";
              end = "60G";
              priority = 2;
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/tmp";
              };
            };
            "var" = {
              start = "60G";
              end = "100G";
              priority = 3;
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
