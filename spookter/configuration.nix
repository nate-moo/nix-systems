# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, inputs, pkgs, pkgsUnstable, ... }:

{

  _module.args.pkgsUnstable = import inputs.nixpkgs {
    inherit (pkgs.stdenv.hostPlatform) system;
    inherit (config.nixpkgs) config;
  };

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./overlays.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "spookter"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  
  services.desktopManager = {
    plasma6.enable = true;
  };

  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;
  programs.waybar.enable = true;
# programs.uwsm = {
#   enable = true;
#   waylandCompositors = {
#     hyprland = {
#       prettyName = "Hyprland";
#       comment = "Hyprland compositor managed by UWSM";
#       binPath = "/run/current-system/sw/bin/Hyprland";
#     };

#   };
# };
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  security.krb5 = {
    enable = true;
    
    settings = {
      libdefaults = {
        default_realm = "DS.AS213801.NET";
      };

      realms = {
        "DS.AS213801.NET" = {
          kdc = [
  	    "freeipa.ds.as213801.net:88"
	  ];
	  master_kdc = "freeipa.ds.as213801.net:88";
	  kpasswd_server = "freeipa.ds.as213801.net:464";
	  default_domain = "ds.as213801.net";
	  admin_server = "freeipa.ds.as213801.net:749";
        };
      };
    };
  };
  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  services.fwupd.enable = false;
  services.tailscale.enable = true;

  services.flatpak.enable = true;
  security.wrappers."mount.nfs" = {
    setuid = true;
    owner = "root";
    group = "root";
    source = "${pkgs.nfs-utils.out}/bin/mount.nfs";
  };
 
  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;
  
  virtualisation.spiceUSBRedirection.enable = true;

  programs.wireshark.enable = true;
  programs.wireshark.usbmon.enable = true;
  programs.gphoto2.enable = true;
  
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/nathan/nix-systems"; # sets NH_OS_FLAKE variable for you
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nathan = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "Nate";
    extraGroups = [ "networkmanager" "wheel" "docker" "adbusers" "wireshark" "camera" "docker" "libvirtd" "dialout" ];
    packages = with pkgs; [
      go
      mpv
      qdmr

      remmina

      darktable

      wireshark

      docker

      nodejs_24
      jq

      vesktop
      kdePackages.kate
      
      rofi
      dunst
      
      # thunderbird
      fastfetch
      virt-viewer
      btop
      nomacs
      kitty
      wineWow64Packages.stable
      winbox4
      usbtop

      blender

      jetbrains.clion
      jetbrains.goland
      libgcc
      clang
      gdb

      virtiofsd

      libreoffice-qt6-fresh

      dig
      eza
      bat
      fzf
      zsh
      oh-my-posh

      zoxide

      git

      chirp

      signal-desktop

      k9s
      kubectl
      talosctl
      
      hyprshot
      hyprpaper
    ] ++ [ pkgsUnstable.antigravity-fhs ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  services.ollama.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    aria2
    neovim
    proxmox-backup-client

    btrfs-progs
    nfs-utils
    ntfs3g
    exfat
    exfatprogs
    usbutils
    pciutils

    gnumake
    clang
    gcc

    kdiskmark 
  ];

  systemd.user.services.proxmox-backup = {
    description = "Proxmox Backup Client — home directory";
    # Make sure we have network before attempting the backup
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    serviceConfig = {
      Type = "oneshot";
      User = "nathan";
      Group = "users";
      Nice = 10;
      IOSchedulingClass = "best-effort";
      IOSchedulingPriority = 7;
    };

    environment = {
      # Set these as appropriate for your setup:
      PBS_REPOSITORY = "nate@pbs!auto-backup@10.69.1.22:HDD-Raid";
      PBS_PASSWORD = "3623b44a-2d9b-4d64-bd67-1dd5bc633877";
      PBS_FINGERPRINT = "a9:2b:c5:28:57:6d:34:74:f0:e6:f6:e4:7e:2d:25:88:24:6c:b8:d5:00:32:e3:b4:b9:32:3c:02:ff:6c:3f:9f";
    };

    # If you prefer to keep secrets out of the Nix store, point to a
    # root-readable file (mode 600) instead of using `environment` above:
    # serviceConfig.EnvironmentFile = "/etc/proxmox-backup/env";

    path = with pkgs; [
      proxmox-backup-client
      util-linux  # for `logger`, used in the postStart line below
    ];

    script = ''
      ${pkgs.proxmox-backup-client}/bin/proxmox-backup-client \
        backup home.pxar:/home/nathan \
    '';

    # Optional: log completion to syslog/journal
    postStart = ''
      ${pkgs.util-linux}/bin/logger -t proxmox-backup \
        "Backup completed with status $?"
    '';
  };

  systemd.user.timers.proxmox-backup = {
    description = "Run Proxmox backup every few days of activity";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # Monotonic timer: counts time since the service last became inactive.
      # Pauses while the laptop is suspended, so it measures "awake time".
      OnUnitInactiveSec = "3d";
      Persistent = true;
      AccuracySec = "1h";
    };
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    nerd-fonts.caskaydia-mono
    nerd-fonts.caskaydia-cove
    source-sans-pro
    source-sans
    source-han-sans
    material-icons
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.steam.enable = true;
  programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  networking.extraHosts = ''
    10.69.1.10 freeipa.ds.as213801.net freeipa
  '';

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
