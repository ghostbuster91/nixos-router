{ buildArmTrustedFirmware
, dtc
, fetchFromGitHub
, ubootBananaPiR3
, ubootTools
, ...
}:
{
  # TODO: Remove fip from extraMakeFlags, and do not pass uboot into this build.
  # Build and package ./tools/fiptool/fiptool or work out how to use the fiptool.py in uboot binman.
  # Build uboot, build this, commbine the two with fiptool create --soc-fw bl32.bin --nt-fw u-boot.bin u-boot.fip
  armTrustedFirmwareMT7986 = (buildArmTrustedFirmware rec {
    extraMakeFlags = [ "USE_MKIMAGE=1" "DRAM_USE_DDR4=1" "BOOT_DEVICE=sdmmc" "BL33=${ubootBananaPiR3}/u-boot.bin" "all" "fip" ];
    platform = "mt7986";
    extraMeta.platforms = [ "aarch64-linux" ];
    filesToInstall = [ "build/${platform}/release/bl2.img" "build/${platform}/release/fip.bin" ];
  }).overrideAttrs (oldAttrs: {
    src = fetchFromGitHub {
      owner = "mtk-openwrt";
      repo = "arm-trusted-firmware";
      # mtksoc HEAD 2023-03-10
      rev = "7539348480af57c6d0db95aba6381f3ee7483779";
      hash = "sha256-OjM+metlaEzV7mXA8QHYEQd94p8zK34dLTqbyWQh1bQ=";
    };
    version = "2.7.0-mtk";
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ dtc ubootTools ];
  });
}
