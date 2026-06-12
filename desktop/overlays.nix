{ config, pkgs, lib, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      qdmr = prev.qdmr.overrideAttrs (old: {
          pname = "qdmr";
          version = "0.15.0";
          src = prev.fetchFromGitHub {
            owner = "hmatuschek";
            repo = "qdmr";
            rev = "3db0b2f4ade5e6c2a818ecc6f410f0a19087b32e";
            hash = "sha256-u+f1wZn1Uha4OzSI40e5uSH4wL9Fl4iLHSy6HituL44=";
          };
          buildInputs = (old.buildInputs or []) ++ [ final.qt6.qtmultimedia ];
          postPatch = builtins.replaceStrings ["--replace"] ["--replace-fail"] (old.postPatch or "");
        });
      })
  ];
}
