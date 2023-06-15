{ lib, pkgs, ... }: {
  imports = [ ./network.nix ];
  system.stateVersion = lib.mkDefault "22.11";

  powerManagement.cpuFreqGovernor = "ondemand";

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "no";
  services.openssh.settings.PasswordAuthentication = false;
  users.users.kghost = {
    name = "kghost";
    home = "/home/kghost";
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFFeU4GXH+Ae00DipGGJN7uSqPJxWFmgRo9B+xjV3mK4" ];
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
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
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

    # system tools
    sysstat
    lm_sensors # for `sensors` command

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
  ];

  # replace default editor with neovim
  environment.variables.EDITOR = "nvim";
}
