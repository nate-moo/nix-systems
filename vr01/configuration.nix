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
    "10-ether0" = {
      matchConfig.MACAddress = "00:16:f0:65:ce:46";
      linkConfig.Name = "ether0";
    };
    "10-ether1" = {
      matchConfig.MACAddress = "00:16:f0:c1:4a:4b";
      linkConfig.Name = "ether1";
    };
    "10-ether2" = {
      matchConfig.MACAddress = "00:16:f0:de:72:ad";
      linkConfig.Name = "ether2";
    };
  };

  networking = {
    nameservers = [ "23.142.248.1" ];
    hostName = "vr01"; # Define your hostname.
    firewall.enable = false;
    networkmanager.enable = false;
    wireguard.interfaces = {
      "44net.1" = {
        ips = [
          "10.2.3.1/24"
          "44.30.111.1/27"
        ];

        listenPort = 51921;
        privateKeyFile = "/var/lib/wireguard/44net-1.key";

        mtu = 1360;
        table = "off"; # Table = off

        peers = [
          {
            publicKey = "SZ8bJ07Tz/pu9Z3rR5gbGVvr0DZ70tl4oiUWwtGVP0g=";
            presharedKeyFile = "/var/lib/wireguard/44net-1-router.psk";
            allowedIPs = [ "0.0.0.0/0" ];
          }
        ];

        postSetup = ''
          ip route add 44.30.111.3/32 via 10.2.3.2 dev 44net.1
        '';
      };

      "44net.3" = {
        ips = [ "10.0.2.1/30" ];
        listenPort = 51819;
        privateKeyFile = "/var/lib/wireguard/44net-3.key";

        peers = [
          {
            publicKey = "K3dyDVDrAdupNsFZYBquEuHGuWGiZl64wDQlPREf52o=";
            presharedKeyFile = "/var/lib/wireguard/44net-3.psk";
            allowedIPs = [
              "10.0.2.0/30"
              "44.30.111.210/32"
            ];
          }
        ];
      };

    };
    interfaces = {
      ether0 = {
        ipv6 = {
          addresses = [
            {
              address = "2602:f9ba:69::237";
              prefixLength = 48;
            }
          ];
        };
      };
      ether1 = {
        ipv6 = {
          addresses = [
            {
              address = "2602:fa3d:f4:1::cb";
              prefixLength = 64;
            }
          ];
        };
        ipv4 = {
          addresses = [
            {
              address = "149.112.75.30";
              prefixLength = 24;
            }
          ];
        };
      };
      ether2 = {
        ipv6 = {
          addresses = [
            {
              address = "2602:f766:f::2";
              prefixLength = 64;
            }
          ];
        };
        # ipv4 = { addresses = [ { address = ""; prefixLength = 24; } ]; };
      };
    };

  };

  boot.kernelParams = [ "console=ttyS0,115200n8" ];

  # Set your time zone.
  time.timeZone = "America/Denver";

  users.users.root.hashedPassword = "$y$j9T$QPBGLGnIF96dPpmu0mDLH1$k8m.9Is3VBXmp3ix8vbcM5kbcGlGZXWCXWJd9vC7to7";

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

  services.bird.enable = true;
  services.bird.checkConfig = false;
  services.bird.config = ''
    include "/var/lib/pathvector/configdir/bird.conf";
  '';

  systemd.tmpfiles.rules = [
    "L+ /etc/bird/protocols.json - - - - /var/lib/pathvector/configdir/protocols.json"
  ];

  systemd.services.labv6gre = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    path = with pkgs; [ iproute2 ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ip -6 tunnel add labv6gre mode ip6gre local 2602:f9ba:69::237 remote 2601:282:100:7f08::1 encaplimit none || true
      ip addr add fd00:69::1/126 dev labv6gre || true
      ip link set labv6gre mtu 1440 up
    '';
  };

  systemd.services.vrtun = {
    enable = false;
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    path = with pkgs; [ iproute2 ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ip -6 tunnel add vrtun mode gre local 23.168.24.237 remote 103.204.195.9 encaplimit none || true
      ip addr add fd00:69::1/126 dev labv6gre || true
      ip link set labv6gre mtu 1440 up
    '';
  };

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
