{
  config,
  pkgs,
  lib,
  ...
}:

{
  nixpkgs.overlays = [
    #(final: prev: {
    #qdmr = prev.qdmr.overrideAttrs (old: {
    #pname = "qdmr";
    #version = "0.15.0";
    #src = prev.fetchFromGitHub {
    #owner = "hmatuschek";
    #repo = "qdmr";
    #rev = "3db0b2f4ade5e6c2a818ecc6f410f0a19087b32e";
    #hash = "sha256-u+f1wZn1Uha4OzSI40e5uSH4wL9Fl4iLHSy6HituL44=";
    #};
    #buildInputs = (old.buildInputs or [ ]) ++ [ final.qt6.qtmultimedia ];
    #postPatch = builtins.replaceStrings [ "--replace" ] [ "--replace-fail" ] (old.postPatch or "");
    #});
    #})

    (final: prev: {
      imgbrd-grabber = final.stdenv.mkDerivation (finalAttrs: {
        pname = "imgbrd-grabber";
        version = "7.14.0";

        src = prev.fetchFromGitHub {
          owner = "Bionus";
          repo = "imgbrd-grabber";
          tag = "v${finalAttrs.version}";
          hash = "sha256-HvbbUZTyrT+3aZLSNk8I34gg7p4crfauHE3qC065+AI=";
          fetchSubmodules = true;
        };

        buildInputs =
          with prev.qt6;
          [
            qtbase
            qtdeclarative
            qttools
            qtnetworkauth
            qtmultimedia
          ]
          ++ [
            prev.openssl
            prev.libpulseaudio
            prev.typescript
            prev.nodejs
          ];

        nativeBuildInputs = [
          prev.makeWrapper
          prev.qt6.wrapQtAppsHook
          prev.cmake
        ];

        extraOutputsToLink = [ "doc" ];

        preBuild = ''
          export HOME=$TMPDIR

          # the package.sh script provides some install helpers
          # using this might make it easier to maintain/less likely for the
          # install phase to fail across version bumps
          patchShebangs ../scripts/package.sh
        '';

        patches = [
          ./cmake4-compat.patch
        ];

        postPatch = ''
          # the npm build step only runs typescript
          # run this step directly so it doesn't try and fail to download the unnecessary node_modules, etc.
          substituteInPlace ./sites/CMakeLists.txt --replace-fail "npm install" "npm run build"

          # link the catch2 sources from nixpkgs
          ln -sf ${prev.catch2.src} tests/src/
        '';

        postInstall = ''
          # move the binaries to the share/Grabber folder so
          # some relative links can be resolved (e.g. settings.ini)
          mv $out/bin/* $out/share/Grabber/

          cd ../..
          # run the package.sh with $out/share/Grabber as the $APP_DIR
          sh ./scripts/package.sh $out/share/Grabber

          # add symlinks for the binaries to $out/bin
          ln -s $out/share/Grabber/Grabber $out/bin/Grabber
          ln -s $out/share/Grabber/Grabber-cli $out/bin/Grabber-cli
        '';

        sourceRoot = "${finalAttrs.src.name}/src";

        meta = {
          description = "Very customizable imageboard/booru downloader with powerful filenaming features";
          license = prev.lib.licenses.asl20;
          homepage = "https://bionus.github.io/imgbrd-grabber/";
          mainProgram = "Grabber";
          maintainers = with prev.lib.maintainers; [
            evanjs
            luftmensch-luftmensch
          ];
        };
      });
    })
  ];
}
