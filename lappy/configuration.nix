# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ 
config, 
pkgs,
inputs,
... 
}:
let
  av1an-svt = pkgs.av1an.override {
    withSvtav1 = true;
  };

in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  nixpkgs.overlays = [
  
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  #swapDevices = [ {
  #  device = "/dev/nvme0n1p5";
  #} ];
  #boot.extraModulePackages = with config.boot.kernelPackages; [];

  networking.hostName = "nixlappy"; # Define your hostname.
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


  services.hardware.bolt.enable = true;

  hardware.keyboard.qmk.enable = true;
  hardware.bluetooth.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the Budgie Desktop environment.
#  services.xserver.displayManager.sddm.enable = true;
#  services.xserver.desktopManager.budgie.enable = true;

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    konsole
    oxygen
  ];

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  systemd.user.services.kanshi = {
    description = "kanshi daemon";
    serviceConfig = {
      Type = "simple";
      ExecStart = ''${pkgs.kanshi}/bin/kanshi -c kanshi_config_file'';
    };
  };



  # Configure keymap in X11
  services.xserver.xkb = rec {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.flatpak.enable = true;
  security.wrappers."mount.nfs" = {
    setuid = true;
    owner = "root";
    group = "root";
    source = "${pkgs.nfs-utils.out}/bin/mount.nfs";
  };

  # Enable sound with pipewire.
#  sound.enable = true;
  services.pulseaudio.enable = false;
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

  programs.virt-manager.enable = true;
  
  users.groups.libvirtd.members = ["nathan"];
  
  virtualisation.libvirtd.enable = true;
  
  virtualisation.spiceUSBRedirection.enable = true;

  programs.wireshark.enable = true;
  programs.wireshark.usbmon.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nathan = {
    isNormalUser = true;
    description = "nathan";
    extraGroups = [ "networkmanager" "wheel" "video" "adbusers" "docker" ];
    packages = with pkgs; [
      darktable
      nasm
      ghidra-bin

      tcpdump

      arduino-ide
      aria2

      wireshark

      # IDEs
      jetbrains.clion
      jetbrains.webstorm
      jetbrains.idea-ultimate
      jetbrains.datagrip
      jetbrains.goland
      jetbrains.pycharm-community
      jetbrains-toolbox

      zulu
      zulu11
      zulu17
      zulu23
      zulu8

      zip
      unzip

      hyprpaper
      wofi
      nomacs

      pavucontrol

      dig
      wl-clipboard
      waybar
      slurp
	
      wireshark
      kdiskmark
      iperf

      # Dev tooling
      nodejs
      pnpm
      clang
      gcc
      adoptopenjdk-icedtea-web
      gdb
      git
      virt-viewer
      wineWowPackages.stable
      libcap 
      go 
      python311
      python311Packages.pip
      python311Packages.numpy
      python311Packages.pandas
      gnumake

      rars
      fastfetch

      typst
      wireguard-tools
      
      # Other goodies
      remmina
      #winbox4
      mpv
      mpv-unwrapped.dev
      jellyfin-media-player
      libreoffice-qt6-fresh

      tree
      prismlauncher
      parsec-bin
      vesktop
      discord
      gphoto2
      #imgbrd-grabber

      alacritty
      k9s
      kubectl
      talosctl

      firefox
      thunderbird
      signal-desktop
      moonlight-qt

      av1an-svt

      kdePackages.breeze
      hyprcursor
      nwg-look
      
      ffmpeg-full
      yt-dlp
      
      winbox4
    ];
  };

  programs.adb.enable = true;
  services.ollama.enable = true;

  services.cron.enable = true;
  services.cron.systemCronJobs = [
    "0 0,12 * * * sync    rsync -azE -e \"ssh -i .ssh/scale\" /home/nathan truenas_admin@10.69.1.100:/mnt/BiggusDickus/backups/laptop/home"
  ];

  services.syncthing = {
    enable = true;
    group = "users";
    user = "nathan";
    dataDir = "/home/nathan/sync/Documents";
    configDir = "/home/nathan/Documents/sync/.config/syncthing";
    settings = {
      devices = {
        NAS.id = "";
      };
      folders = {
        Kubernetes = {
          path = "/home/nathan/Documents/sync/kubernetes";
	  devices = ["NAS"];
	};
      };
    };
  };

  programs.steam.enable = true;
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  programs.hyprland = {
    # Install the packages from nixpkgs
    enable = true;
    # Whether to enable XWayland
    xwayland.enable = true;
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    flake = "/etc/nixos/";
  };

  services.globalprotect = {
    enable = true;
    #csdWrapper = "${pkgs.openconnect}/libexec/openconnect/hipreport.sh";
  };

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "client";

  virtualisation.docker.enable = true;
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
    btop
  
    globalprotect-openconnect
    via
    
    dunst

    btrfs-progs
    nfs-utils
    ntfs3g
    exfat
    exfatprogs
    usbutils
    pciutils

    qemu

    kdePackages.qtstyleplugin-kvantum
    (pkgs.buildFHSEnv {
      name = "fhs";
      targetPkgs = pkgs: with pkgs; [
        alsa-lib atk cairo cups curl dbus expat file fish fontconfig freetype
        fuse glib gtk3 libGL libnotify libxml2 libxslt netcat nspr nss openjdk8
        openssl.dev pango pkg-config strace udev vulkan-loader watch wget which
        xorg.libX11 xorg.libxcb xorg.libXcomposite xorg.libXcursor
        xorg.libXdamage xorg.libXext xorg.libXfixes xorg.libXi xorg.libXrandr
        xorg.libXrender xorg.libXScrnSaver xorg.libxshmfence xorg.libXtst
        xorg.xcbutilkeysyms zlib fontconfig.lib
      ];
      profile = ''export FHS=1'';
      runScript = "fish";
    })
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.

  services.udev.packages = [ pkgs.via ];
  
  programs.mtr.enable = true;
  programs.light.enable = true;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
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

  environment.sessionVariables = rec {
    NIXOS_OZONE_WL = "1";

    XDG_DATA_DIRS = [
      "/var/lib/flatpak/exports/share"
      "/home/nathan/.local/share/flatpak/exports/share"
    ];
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  networking.hosts = {
    "10.69.1.210" = ["kube.clusterfuck.local"];
    "10.69.1.212" = ["kube.clusterfuck.local"];
    "10.69.1.214" = ["kube.clusterfuck.local"];
  };

  fileSystems = {
    "/".options = [ "compress=zstd" ];
    "/home".options = [ "compress=zstd" ];
    "/nix".options = [ "compress=zstd" "noatime" ];
    "/home/nathan/mnt/biggus" = {
      device = "10.69.1.100:/mnt/BiggusDickus";
      fsType = "nfs";
      options = [
        "rw"
	"_netdev"
	"nofail"
	"noauto"
	"user"
      ];
    };
  };


  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
