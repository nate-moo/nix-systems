# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, lib, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./timers.nix
      #./overlays.nix
    ];

  # Enabling flakes and the nix command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # BAD
  nixpkgs.config = {
    permittedInsecurePackages = [
      "olm-3.2.16"
      "dotnet-sdk-wrapped-7.0.410"
      "dotnet-sdk-7.0.410"
      "dotnet-runtime-wrapped-7.0.20"
      "dotnet-runtime-7.0.20"
      "dotnet-core-combined"
      "dotnet-sdk-6.0.428"
      "dotnet-sdk-wrapped-6.0.428"
      "qtwebengine-5.15.19"
    ];
    allowBroken = true;
    android_sdk.accept_license = true;
  };
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "max";
  boot.loader.efi.canTouchEfiVariables = true;

  # Udev Rules
  services.udev.extraRules = ''
SUBSYSTEM=="cpu", ACTION=="add", TEST=="online", ATTR{online}=="0", ATTR{online}="1"
SUBSYSTEM=="memory", ACTION=="add", TEST=="state", ATTR{state}=="offline", ATTR{state}="online"
  '';

  services.nfs.server = {
    enable = true;
    exports = ''
#/home/nathan *(rw,anonuid=0,anongid=0,all_squash)
    '';
  };

  # Setting the kernel
  ## linuxPackages_latest
  ## linuxPackages -- (Most likely default)
  ## linuxPackages_zen

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Additional Kernel Params
  boot.kernelParams = [ 
    "amdgpu.ppfeaturemask=0xfff7ffff" 
    "resume_offset=48752640"
  ]; 

  boot.resumeDevice = "/dev/disk/by-uuid/2ee11375-6999-431d-a160-32bd213dbc83";

  # Additional Kernel Modules
  #boot.extraModulePackages = with config.boot.kernelPackages; [ usbip ];

  boot.initrd.kernelModules = [ "amdgpu" ];

  #boot.supportedFilesystems = [ "zfs" ];

  # -- Auto Loading -- #
  #boot.kernelModules = [  ];

  security.krb5 = {
    enable = true;
    settings = {

      libdefaults = {
        default_realm = "DS.AS213801.NET";
      };

      domain_realm = {
        ".ds.as213801.net" = "DS.AS213801.NET";
        "ds.as213801.net" = "DS.AS213801.NET";
        "freeipa.ds.as213801.net" = "DS.AS213801.NET";
      };

      realms = {
        "DS.AS213801.NET" = {
          admin_server = "freeipa.ds.as213801.net:749";
          kpasswd_server = "freeipa.ds.as213801.net:464";
          master_kdc = "freeipa.ds.as213801.net:88";
          kdc = [
            "freeipa.ds.as213801.net:88"
          ];
        };
      };
    };
  };

  security.ipa = {
    enable = false;
    realm = "DS.AS213801.NET";
    domain = "ds.as213801.net";
    server = "freeipa.ds.as213801.net";
    ipaHostname = "nixos.ds.as213801.net";
    certificate = pkgs.fetchurl {
      url = "http://freeipa.ds.as213801.net/ipa/config/ca.crt";
      sha256 = "16bk2fdxzigm508i29rpmgbp2kpd75dzr58m7a2kv7jz0gjs396j";
    };
    basedn = "dc=ds,dc=as213801,dc=net";
    ifpAllowedUids = [
      "root"
      "nathan"
      "nmoore"
    ];
    dyndns.interface = "vlan100";
  };
  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = false;
  #boot.initrd.systemd.network.wait-online.enable = true;
  #systemd.network.wait-online.enable = true;

  networking = {
    nameservers = [ "10.69.1.1" ];#"2602:f766:b:4000::1" ];
    defaultGateway = "10.69.1.1";
    hostId = "7fd0a66b";
  #  dhcpcd.extraConfig = "nohook resolv.conf";
  #  networkmanager.dns = "none";
    resolvconf.extraOptions = [
      #"options no-aaaa"
    ];
    vlans = {
      vlan150 = { id=150; interface="eth2"; };
      vlan100 = { id=100; interface="eth2"; };
      vlan10  = { id=10;  interface="eth2"; };
    };
    interfaces = {
      vlan150.ipv6.addresses = [{
        address = "2602:f766:b:3::90";
        prefixLength = 64;
      }];
      vlan100.ipv4.addresses = [{
        address = "192.168.0.220";
        prefixLength = 24;
      }];
      vlan10.ipv4 = {
        addresses = [{
          address = "10.69.1.90";
          prefixLength = 24;
        }];
        routes = [{
          address = "0.0.0.0";
          prefixLength = 0;
          via = "10.69.1.1";
        }];
      };
      eth2.useDHCP = false;      
#      eth2.ipv4.addresses = [{
#        address = "10.69.1.90";
#	    prefixLength = 24;
#      }];
#      eth2.ipv6.addresses = [{
#        address = "2602:f766:b:4000::90";
#	 prefixLength = 50;
#      }];
    };
  };

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
  services.xserver.enable = true;
  
  services.xserver.displayManager.startx.enable = true;

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  
  services.desktopManager.plasma6.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.displayManager.defaultSession = "none+i3";

  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "i3";
  
  powerManagement.enable = true;

  hardware.keyboard.qmk.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Start ISCSI stuff on login
  systemd.user.services.iscsi-init = { 
    description = "initiates iscsi"; 
    script = '' /home/nathan/.local/bin/iscsi-init ''; 
    wantedBy = [ "multi-user.target" ]; # starts after login 
  };

  # Enable 32bit OGL
  hardware.graphics = {
    enable = true;
  };

  services.xserver.videoDrivers = [ "amdgpu" ];

  services.picom = {
    enable = true;
    vSync = true;
    backend = "glx";
  };

  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr.icd
  ];

  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  # Virtualization
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # Enabling Docker
  virtualisation.docker.enable = true;

  # Enable sound with pipewire.
  # sound.enable = true; ## Deprecated
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    extraConfig.pipewire-pulse = {
      "20-upmix" = {
	"stream.properties" = {
    	  "channelmix.upmix"        = true;
          "channelmix.upmix-method" = "psd";  # none, simple
          "channelmix.lfe-cutoff"   = 250;
          "channelmix.fc-cutoff"    = 12000;
          "channelmix.rear-delay"   = 12.0;
        };
      };
    };
  };

  services.globalprotect = {
    enable = false;
    csdWrapper = "${pkgs.openconnect}/libexec/openconnect/hipreport.sh";
  };

  programs.noisetorch.enable = true;
  programs.zsh.enable = true;
  programs.fish.enable = true;
  programs.nh.enable = true;
  programs.nh.flake = "/home/nathan/nix";
  programs.chromium.enable = true;

  #android_sdk.accept_license = true;

  nix.settings.trusted-users = [ "root" "nathan" ];
  users.users.nathan = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "Nathan Moore";
    extraGroups = [ "networkmanager" "wheel" "libvirt" "docker" "adbusers" "dialout" "wireshark" ];
    packages = with pkgs; [
      zoxide
      eza
      bat
      zsh
      oh-my-posh

      arduino-ide

      #globalprotect-openconnect
      mprocs

      kitty

      qrencode

      fish
      fishPlugins.tide

      jq

      archivemount
      winbox4
      zip
      lf
      smartmontools
      yt-dlp
      wireshark
      anki-bin

      iperf3

      imagemagick
      gphoto2
      gpu-screen-recorder-gtk
      hugin

      ryubing
      heroic
      wayvnc
      vesktop

      # Jetbrains
      jetbrains.clion
      jetbrains.webstorm

      jetbrains.idea-community
      zulu8

      jetbrains.datagrip

      jetbrains.goland
      go

      android-studio

      nodejs_24

      fastfetch
      #jellyfin-media-player
      prismlauncher
      signal-desktop-bin
      dig
      p7zip

      postgresql
      screen

      talosctl
      kubectl
      k9s
      kubernetes-helm

      amdgpu_top
      #ollama

      #jetbrains.idea-community-bin

      (pkgs.wrapFirefox (pkgs.firefox-unwrapped.override { pipewireSupport = true;}) {})
      ungoogled-chromium
      libnotify # Possibly fixing notification issues with firefox

      maim
      xclip

      wmname
      kdePackages.kate
      mpv
      remmina
      bs-manager
      tor-browser
      nomacs
      mtr
      parsec-bin
      gnupg
      kdePackages.kgpg
      goverlay
      wine
      protontricks
      steamtinkerlaunch
      virt-viewer
      blender-hip
      jellyfin-mpv-shim
      wireguard-tools
      obs-studio
      darktable
      zoom-us
      lunarvim
      bottles
      wl-clipboard
      btop
      hugo
      legcord
      glxinfo
      youtube-music
      waypipe
      tiny
      kdePackages.kdenlive
      openssl
      # zluda

      nvtopPackages.amd
      radeontop

      lxqt.pcmanfm-qt
      lxqt.lxqt-menu-data
      lxqt.lxqt-themes
      lxqt.pavucontrol-qt
      
      # Python
      python311
      python311Packages.pip
      python311Packages.requests
      #python311Packages.httpx
      python311Packages.beautifulsoup4

      thunderbird

      picom
    ];
  };

  # Waydroid
  virtualisation.waydroid.enable = true;

  #services.ceph.enable = false;
  #services.ceph.client.enable = false;
  #services.ceph.global.fsid = "4b9a71e8-7d89-4dfc-ad16-af5006db2373";
  #services.ceph.global.clusterNetwork = "10.69.1.0/24";
  #services.ceph.global.monHost = "10.69.1.27, 10.69.1.26, 10.69.1.24";
  #services.ceph.global.monInitialMembers = "10.69.1.27, 10.69.1.24, 10.69.1.26";

  services.sunshine = {
    enable = true;
    capSysAdmin = true;
  };

  # File Manager Stuff
  services.samba = {
    enable = false;
    package = pkgs.sambaFull;
  };

  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.devmon.enable = true;

  services.tailscale.enable = true;

  # ollama
  services.ollama = {
    enable = false;
    acceleration = "rocm";
    environmentVariables = {
      HSA_OVERRIDE_GFX_VERSION = "11.0.0";
    };
  };


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # Enable ADB
  programs.adb.enable = true;
  programs.gpu-screen-recorder.enable = true;
  services.udev.packages = [
    pkgs.via
  ];

  # Name the default network interface
  networking.usePredictableInterfaceNames = false;

  # hyprland
  programs.hyprland.enable = false;

  # direnv
  programs.direnv.enable = true;

  environment.systemPackages = with pkgs; [
    # Misc tools and programs
    nfs-utils
    flatpak
    gparted
    gamescope
    wget
    corectrl
    mangohud
    usbutils
    mtpfs
    ocs-url
    appimage-run
    qt6.qtmultimedia
    ntfs3g
    fzf
    kdiskmark
    pciutils
    helvum
    lxqt.lxqt-policykit
    gdu

    #ceph-client
    btrfs-progs

    # sway config
    polybarFull
    #mako
    dunst
    waybar
    wofi
    rofi
    feh
    alacritty
    swaybg
    xdg-desktop-portal-wlr

    # Wayland Screenshot
    grim
    slurp

    # c/cpp deps
    gcc
    gnumake

    # libsForQt5
    kdePackages.kio-extras
    # libsForQt5.libqtav -- Removed
    kdePackages.qtmultimedia
    kdePackages.phonon
    kdePackages.kdeconnect-kde
    kdePackages.plasma-browser-integration
    #kdePackages.xdg-desktop-portal-kde
    kdePackages.plasma-workspace


    # Steam Tinker Launch Deps
    unzip
    xdotool
    unixtools.xxd
    yad
    xorg.xwininfo

    # Libre Office
    libreoffice-qt
    hunspell
    hunspellDicts.en_US

    onlyoffice-bin_latest


    # Development resources
    xorg.xhost
    git
    neovim
    docker

    # Filesystems
    cifs-utils
    samba

    # Encoding
    libaom
    rav1e
    svt-av1

    # --
    # codecs and video stuff
    ffmpeg
    gst_all_1.gstreamer
    gst_all_1.gst-vaapi
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-rs
    gst_all_1.gst-libav
    gst_all_1.gst-plugins-base

    # Vulkan Tools
    vulkan-loader
    vulkan-validation-layers
    vulkan-tools

    # --
    openiscsi

    # --
    fuse3
    sshfs

    # -- keyboards
    via

  ] ++ [
    #inputs.quickshell.packages.x86_64-linux.default
  ];

  # SwayFX
  services.gnome.gnome-keyring.enable = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  services.syncthing = {
    enable = false;
    user = "nathan";
    configDir = "/home/nathan/.syncthing";
    settings = {
      folders = {
        "Kubernetes" = {
          path = "/home/nathan/talos";
	  devices = [ "nas" "surface" ];
	};
	"Nix-Config" = {
          path = "/home/nathan/.nixos-config";
	  devices = [ "nas" ];
	};
        "notes" = {
          path = "/home/nathan/tab-notes";
	  devices = [ "nas" "tablet" ];
	  type = "receiveonly";
	};
      };
    };
  };

  programs.dconf.enable = true;

  # Nginx
  services.nginx.enable = true;
  services.nginx.virtualHosts = rec {
    "jellyfin-lab.naed3r.xyz" = {
      addSSL = true;
      serverAliases = [
        "jellyfin"
      ];
      #forceSSL = true;
      sslCertificate = "/etc/ssl/certs/jellyfin-self.crt";
      sslCertificateKey = "/etc/ssl/certs/jellyfin-self.key";
      locations."/" = {
        proxyPass = "http://10.69.1.223:8096";
        proxyWebsockets = true;
      };
    };

    #services.nginx.virtualHosts.
    "truenas.naed3r.xyz" = {
      addSSL = true;
      sslCertificate = "/etc/ssl/certs/jellyfin-self.crt";
      sslCertificateKey = "/etc/ssl/certs/jellyfin-self.key";
      serverAliases = [
        "truenas"
      ];
      locations."/" = {
        proxyPass = "https://10.69.1.103";
        proxyWebsockets = true;
      };
    };

    "immich.naed3r.xyz" = {
      addSSL = true;
      serverAliases = [
        "immich"
      ];
      #forceSSL = true;
      sslCertificate = "/etc/ssl/certs/jellyfin-self.crt";
      sslCertificateKey = "/etc/ssl/certs/jellyfin-self.key";
      locations."/" = {
        proxyPass = "http://10.69.1.224:3001";
        proxyWebsockets = true;
      };
    };

    "nextcloud.naed3r.xyz" = {
      addSSL = true;
      serverAliases = [
        "nextcloud"
      ];
      #forceSSL = true;
      sslCertificate = "/etc/ssl/certs/jellyfin-self.crt";
      sslCertificateKey = "/etc/ssl/certs/jellyfin-self.key";
      locations."/" = {
        proxyPass = "https://10.69.1.221";
        proxyWebsockets = true;
      };
    };
  };

  networking.extraHosts = ''
  127.0.0.1      jellyfin-lab.naed3r.xyz
  127.0.0.1      truenas.naed3r.xyz
  127.0.0.1      immich.naed3r.xyz
  127.0.0.1      nextcloud.naed3r.xyz
  
  138.67.208.153 oreprint.mines.edu
  138.67.190.221 isengard.mines.edu
  138.67.208.30  mio-ondemand.mines.edu
  138.67.212.56  ada.mines.edu

  10.69.1.10     freeipa.ds.as213801.net

  10.69.1.210    kube.clusterfuck.local
  10.69.1.212    kube.clusterfuck.local
  '';
  # 10.69.1.214    kube.clusterfuck.local
  # '';

  networking.firewall.enable = false;

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings.PasswordAuthentication = true;
    settings.KbdInteractiveAuthentication = true;
    settings.X11Forwarding = true;

  };

  # Enables flatpak
  services.flatpak.enable = true;

  xdg.portal.enable = true;
  xdg.portal.wlr.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  #xdg.portal.config.common.default = "kde";

  # Environment Variables
  environment.variables = {
    XDG_DATA_DIRS = lib.mkForce "/run/opengl-driver/share:$XDG_DATA_DIRS";
  };

  environment.sessionVariables = rec {
    MOZ_ENABLE_WAYLAND = "1";
    XDG_MENU_PREFIX    = "lxqt-";
    XDG_CACHE_HOME     = "$HOME/.cache";
    XDG_CONFIG_HOME    = "$HOME/.config";
    XDG_DATA_HOME      = "$HOME/.local/share";
    XDG_STATE_HOME     = "$HOME/.local/state";

    # Not officially in the specification
    NIXOS_OZONE_WL     = "1";
    XDG_BIN_HOME       = "$HOME/.local/bin";
    PATH = [
      "${XDG_BIN_HOME}"
    ];
    EDITOR             = "nvim";
  };

  environment.pathsToLink = [ "/libexec" ];

  environment.etc."/xdg/menus/plasma-applications.menu".text = builtins.readFile "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

  # Printing
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.brgenml1lpr pkgs.brgenml1cupswrapper pkgs.brlaser ];

  # Install Steam
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;

  # Java
  programs.java.enable = true;

  # Filesystems

  fileSystems."/home/nathan/mnt/Store4" = {
    device = "10.69.1.100:/mnt/BiggusDickus/backups/Store4-Backup";
    fsType = "nfs";
    options = [ "defaults" "rw" "exec" "_netdev" "nofail" ];
  };

  fileSystems."/home/nathan/mnt/Store2" = {
    device = "10.69.1.100:/mnt/BiggusDickus/backups/Store2-Backup";
    fsType = "nfs";
    options = [ "defaults" "rw" "exec" "_netdev" "nofail"];
  };

  fileSystems."/home/nathan/mnt/Media" = {
    device = "10.69.1.100:/mnt/BiggusDickus/core/Media";
    fsType = "nfs";
    options = [ "defaults" "rw" "exec" "_netdev" "nofail"];
  };

  fileSystems."/home/nathan/mnt/nasMisc" = {
    device = "10.69.1.100:/mnt/BiggusDickus/core/SoftwareAndMisc";
    fsType = "nfs";
    options = [ "defaults" "rw" "exec" "_netdev" "nofail"];
  };

  #fileSystems."/home/nathan/mnt/NixStorage" = {
  #  device = "nixstor2@4b9a71e8-7d89-4dfc-ad16-af5006db2373.NixStorage=/";
  #  fsType = "ceph";
  #  options = [ "mon_addr=10.69.1.23:6789/10.69.1.24:6789" "_netdev" "nofail"];
  #};

  fileSystems."/home/nathan/mnt/slimjim" = {
    device = "10.69.1.26:/Temp-Pool/";
    fsType = "nfs";
    options = [ "defaults" "rw" "exec" "_netdev" "nofail"];
  };

#  fileSystems."/home/nathan/mnt/extra" = {
#    device = "/dev/nvme1n1p2";
#    fsType = "btrfs";
#    options = [ "defaults" "rw" "exec" ];
#  };
  
  # iscsi stuff
  services.openiscsi.enable = false;
  services.openiscsi.discoverPortal = "10.69.1.103:3260";
  services.openiscsi.name = "iqn.2005-10.org.freenas.ctl:nix-scsi";
  services.openiscsi.enableAutoLoginOut = true;
  services.openiscsi.extraConfig = ''

  '';

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
  ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

  # Flakes

  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
