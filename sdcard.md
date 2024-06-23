# SD-CARD

**Always umount mmc before running any commands against it!**

Check how much is still in the buffer:

```bash
watch "grep -e Dirty: -e Writeback: /proc/meminfo"
```

Drop the partition table:

```bash
wipefs -a /dev/mmcblk0
```

Flash image on sdcard with progress and decompression on the fly:

```bash
pv result/sd-image/nixos-sd-BananaPi-BPiR3-v0.2.raw.zst | zstdcat | sudo dd of=/dev/mmcblk0 bs=1M oflag=sync
```

Simpler version but less reliable (requires decompression beforehand):

```bash
sudo dd if=nixos-banana2.raw of=/dev/mmcblk0 bs=1M status=progress
```
