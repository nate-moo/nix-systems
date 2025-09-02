{ config, pkgs, lib, ... }:

{
  nixpkgs.overlays = [

# Prism Launcher 8.4
    #( final: prev:
    #{
    #  prismlauncher = prev.prismlauncher.overrideAttrs (oldAttrs: rec {
    #    version = "8.4-1";
#
#        src = prev.fetchFromGitHub {
#          owner = "PrismLauncher";
#          repo = "PrismLauncher";
#          rev = "fc445078cd635119bb8a2090c33c728ce62f6a85";
#          hash = "sha256-or4L+bKsYZyJhrOPWASpZiYpHKA/GqqRRQtV9AZHjbo=";
#	  # sha256 = lib.fakeSha256;
#	  # sha256 = "460hB91M2hZm+uU1tywJEj20oRd5cz/NDvya8/vJdSA=";
#        };
#      });
#    })
    ( final: prev: {
      supercell-wx = prev.supercell-wx.overrideAttrs (oldAttrs: rec {
        version = "0.5.1";

        src = prev.fetchFromGitHub {
          owner = "dpaulat";
          repo = "supercell-wx";
	  fetchSubmodules = true;
          rev = "refs/tags/v0.5.1-release";
          hash = "sha256-odGxf36654JzW7JGD8b8rLP7gDue+nK5q0F1rU0u+Ts=";
	  #sha256 = lib.fakeSha256;
	  # sha256 = "460hB91M2hZm+uU1tywJEj20oRd5cz/NDvya8/vJdSA=";
        };
	patches = [
	    # These are for Nix compatibility {{{
	    ./patches/supercell-wx/use-find-package.patch # Replace some vendored dependencies with Nix provided versions
	    (prev.replaceVars ./patches/supercell-wx/skip-git-versioning.patch {
	      # Skip tagging build with git version, and substitute it with the src revision (still uses current year timestamp)
	      rev = src.rev;
	    })
	    # Prevents using some Qt scripts that seemed to break the install step. Fixes missing link to some targets.
	    ./patches/supercell-wx/fix-cmake-install-corrected.patch
	    # }}}

	    # These may be or already are submitted upstream {{{
	    ./patches/supercell-wx/explicit-link-aws-crt.patch # fix missing symbols from aws-crt-cpp
	    # }}}
	  ];
      });
    })
# Grant's Tiny overlay
#    ( final: prev:
#    {
#      tiny = prev.tiny.overrideAttrs (oldAttrs: rec {
#	version = "0.12.0-1";
#        src = prev.fetchFromGitHub {
#          owner = "grantlemons";
#          repo = "tiny";
#          rev = "08f203fe1d0a456afbde1ce91ce1fd32adf43ead";
#          hash = "sha256-DRhwGub0RWlJYzqs0Hz6lqr/M0so9LLqXYemCblhStU=";
#        };
#
#	doCheck = false;
#      
#        cargoDeps = oldAttrs.cargoDeps.overrideAttrs (lib.const {
#          name = "tiny-vendor.tar.gz";
#          inherit src;
#          outputHash = "sha256-JJR6yuFiqCFAwKjf4Q2eFMWQ9PF7eG+ejw0GdvfrUo8=";
#        });
#      });
#    } )

# Gamescope overlay
#    ( final: prev:
#    {
#      gamescope = prev.gamescope.overrideAttrs (oldAttrs: {
#        src = prev.fetchFromGitHub {
#          owner = "ValveSoftware";
#	  repo = "gamescope";
#          rev = "refs/tags/3.14.1";
#          fetchSubmodules = true;
#          hash = "sha256-lJt6JVolorQdrhumkW9yjyItxqpw6ZtEUbkjNqzHfb8=";
#	};
#      });
#    })
# Goverlay 1.1.1
#    ( final: prev:
#    {
#      goverlay = prev.goverlay.overrideAttrs (oldAttrs: {
#        src = prev.fetchFromGitHub {
#          owner = "benjamimgois";
#	  repo = "goverlay";
#          rev = "refs/tags/1.1.1";
#          fetchSubmodules = true;
#          hash = "sha256-GzybO+CrTRrQ/STYnJDl+8LbonErd6tniRGivbxTZEc=";
#	};
#	patches = [];
#      });
#    })
# Zluda Git
#( final: prev:
#    {
#      zluda = prev.zluda.overrideAttrs (oldAttrs: rec {
#	version = "3.0.0-1";
#        src = prev.fetchFromGitHub {
#          owner = "vosen";
#          repo = "ZLUDA";
#          rev = "27c0e136777a2db49dbb0caa888d561819230493";
#          hash = "sha256-DRhwGub0RWlJYzqs0Hz6lqr/M0so9LLqXYemCblhStU=";
#        };
#
#	doCheck = false;
#      
#        cargoDeps = oldAttrs.cargoDeps.overrideAttrs (lib.const {
#          name = "zluda-vendor.tar.gz";
#          inherit src;
#          outputHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
#        });
#      });
#    } )

  ];
}
