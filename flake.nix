{
  description = "NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    quickshell.url = "github:quickshell-mirror/quickshell";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, quickshell, nixos-hardware, sops-nix, ... }@inputs: {
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

  nixosConfigurations.nixlappy = nixpkgs-stable.lib.nixosSystem {
    # NixLappy
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
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
