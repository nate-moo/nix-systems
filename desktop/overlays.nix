{ config, pkgs, lib, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      qdmr = prev.qdmr.overrideAttrs (oldAttrs: {
        patches = (oldAttrs.patches or [ ]) ++ [
          ./patches/qdmr/anytone_d168uv.patch
        ];
      });
    })
  ];
}
