{ disks ? [ "/dev/vdb" ], ... }: {
  disko.devices = {
    disk = {
      nvme0n1 = {
        device = builtins.elemAt disks 0;
        type = "disk";
        content = {
          type = "table";
          format = "gpt";
          partitions = [
            {
              name = "var-log";
              start = "1MiB";
              end = "20G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/var/log";
              };
            }
            {
              name = "tmp";
              start = "20G";
              end = "60G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/tmp";
              };
            }
            {
              name = "var";
              start = "60G";
              end = "100G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/var";
              };
            }
            {
              name = "swap";
              start = "100G";
              end = "100%";
              content = {
                type = "swap";
                randomEncryption = false;
              };
            }
          ];
        };
      };
    };
  };
}
