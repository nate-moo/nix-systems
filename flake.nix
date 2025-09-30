{
  description = "NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    quickshell.url = "github:quickshell-mirror/quickshell";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";

      # Optional but recommended to limit the size of your system closure.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, lanzaboote, quickshell, nixos-hardware, sops-nix, ... }@inputs: {
    # Desktop
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./desktop/configuration.nix

	#./common/common.nix

	sops-nix.nixosModules.sops
      ];
    };

  nixosConfigurations.spookter = nixpkgs-stable.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ./spookter/configuration.nix
      #./common/common.nix
      sops-nix.nixosModules.sops
      

      nixos-hardware.nixosModules.common-cpu-intel-tiger-lake
      nixos-hardware.nixosModules.common-cpu-intel
      nixos-hardware.nixosModules.common-hidpi
      nixos-hardware.nixosModules.common-pc-laptop-ssd
      nixos-hardware.nixosModules.common-pc-laptop
    ];
  };

  nixosConfigurations.nixlappy = nixpkgs.lib.nixosSystem {
    # NixLappy
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [

      lanzaboote.nixosModules.lanzaboote

      ({ pkgs, lib, ... }: {

          environment.systemPackages = [
            # For debugging and troubleshooting Secure Boot.
            pkgs.sbctl
          ];

          # Lanzaboote currently replaces the systemd-boot module.
          # This setting is usually set to true in configuration.nix
          # generated at installation time. So we force it to false
          # for now.
          boot.loader.systemd-boot.enable = lib.mkForce false;
          boot.lanzaboote = {
            enable = true;
            pkiBundle = "/var/lib/sbctl";
          };
      })

      ./lappy/configuration.nix

      #./common/common.nix

      nixos-hardware.nixosModules.common-cpu-intel
      nixos-hardware.nixosModules.common-hidpi
      nixos-hardware.nixosModules.common-pc-laptop-ssd
      nixos-hardware.nixosModules.common-pc-laptop

      sops-nix.nixosModules.sops
      ];
    };
  };
}
