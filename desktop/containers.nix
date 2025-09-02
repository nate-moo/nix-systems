{ config, pkgs, ... }:

{
  networking.nat = {
    enable = true;
    internalInterfaces = ["ve-+"];
    externalInterface = "ens3";
    # Lazy IPv6 connectivity for the container
    enableIPv6 = true;
  };

  containers.development = {
  autoStart = false;

  config = { config, pkgs, ... }: {
    system.stateVersion = "23.11";
    networking = {
      firewall = {
        enable = true;
      };
    };
  };

  };
}
