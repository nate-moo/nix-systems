# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  systemd.network.links = {
    "10-eth0" = {
      matchConfig.MACAddress = "2:8:20:3d:c1:3c";
      linkConfig.Name = "ether0";
    };
  };

  networking = {
    nameservers = [ "10.69.1.2" ];
    hostName = "neptune"; # Define your hostname.
    firewall.enable = false;
    networkmanager.enable = false;
    interfaces = {
      ether0 = {
        ipv4 = {
          addresses = [
            {
              address = "10.69.1.62";
              prefixLength = 24;
            }
          ];
          routes = [
            {
              address = "0.0.0.0";
              prefixLength = 0;
              via = "10.69.1.100";
            }
          ];

        };
      };
    };

  };

  # Configure network connections interactively with nmcli or nmtui.
  boot.kernelParams = [ "console=ttyS0,115200n8" ];

  # Set your time zone.
  time.timeZone = "America/Denver";

  users.users.root.hashedPassword = "$y$j9T$6AhxErEkoz.f5QwrV0ddL1$mhfhjZN.bQztfEUY1Qh4zQJhrDmSEXUV86rBMcHNP40";

  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     tree
  #   ];
  # };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
    curl
    bgpq4
    bird3
    pathvector
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.nh.enable = true;
  programs.nh.flake = "/root/nix/";
  services.openssh.enable = true;
  services.technitium-dns-server.enable = true;
  services.calibre-server.enable = true;
  services.calibre-server.auth.userDb = "/var/lib/calibre/users.sqlite";
  services.calibre-server.auth.enable = true;
  services.calibre-web.enable = true;
  services.calibre-web.options.enableBookUploading = true;


  services.bird.enable = true;
  services.bird.checkConfig = false;
  services.bird.config = ''
include "/var/lib/pathvector/configdir/bird.conf";
  '';

  systemd.tmpfiles.rules = [
    "L+ /etc/bird/protocols.json - - - - /var/lib/pathvector/configdir/protocols.json"
  ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  
  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.11"; # Did you read the comment?

}
