{ config, lib, pkgs, username, inputs, ... }: {

  imports = [
    ./network.nix
    (import ./disko-config.nix {
      disks = [ "/dev/nvme0n1" ];
    })
    ./monitoring.nix
  ];
  system.stateVersion = lib.mkDefault "22.11";

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
  };

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "no";
  services.openssh.settings.PasswordAuthentication = false;
  users.users.${username} = {
    name = username;
    home = "/home/${username}";
    isNormalUser = true;
    extraGroups = [ "wheel" "network" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFFeU4GXH+Ae00DipGGJN7uSqPJxWFmgRo9B+xjV3mK4" ];
    initialHashedPassword = "$y$j9T$aeZHaSe8QKeC0ruAi9TKo.$zooI/IZUwOupVDbMReaukiargPrF93H/wdR/.0zsrr.";
  };

  system.autoUpgrade = {
    enable = false;
    dates = "weekly";
    flake = inputs.self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "-L"
    ];
    allowReboot = true;
    rebootWindow = {
      lower = "02:00";
      upper = "04:00";
    };
  };

  programs = {
    zsh.enable = true;
    ssh = {
      startAgent = true;
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # enable flakes globally
  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    package = pkgs.nixVersions.stable;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    git # used by nix flakes
    wget
    curl

    neofetch
    nnn # terminal file manager
    bottom # replacement of htop/nmon
    htop
    iotop
    iftop
    nmon

    # system call monitoring
    strace
    ltrace # library call monitoring
    lsof

    mtr # A network diagnostic tool
    iperf3 # A tool for measuring TCP and UDP bandwidth performance
    nmap # A utility for network discovery and security auditing
    ldns # replacement of dig, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    tcpdump # A powerful command-line packet analyzer
    ethtool # manage NIC settings (offload, NIC feeatures, ...)
    dnsutils # dig
    wavemon # Ncurses-based monitoring application for wireless network devices

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    pciutils
    lshw

    # archives
    zip
    xz
    unzip
    p7zip

    # misc
    file
    which
    tree
    gnused
    gnutar
    gawk

    iw
    sops
  ];

  # replace default editor with neovim
  environment.variables.EDITOR = "nvim";
}
