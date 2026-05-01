{
  description = "OpenJDK Flake";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.systems.url = "github:nix-systems/default";
  inputs.flake-utils = {
    url = "github:numtide/flake-utils";
    inputs.systems.follows = "systems";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        igv = pkgs.writeShellApplication {
          name = "igv";
          runtimeInputs = [
            pkgs.bash
            pkgs.jdk25
            pkgs.maven
          ];
          text = ''
            set -eu

            if [ "$#" -gt 1 ]; then
              echo "usage: igv [openjdk-checkout]" >&2
              exit 2
            fi

            find_checkout() {
              dir="$1"
              while [ "$dir" != "/" ]; do
                if [ -f "$dir/src/utils/IdealGraphVisualizer/igv.sh" ]; then
                  printf '%s\n' "$dir"
                  return 0
                fi
                dir=$(dirname "$dir")
              done
              return 1
            }

            if [ "$#" -eq 1 ]; then
              jdk_repo=$1
            elif [ -n "''${IGV_JDK_REPO:-}" ]; then
              jdk_repo=$IGV_JDK_REPO
            else
              jdk_repo=$(find_checkout "$PWD") || {
                echo "Could not find an OpenJDK checkout from the current directory." >&2
                echo "Run igv from inside the checkout, pass the checkout path as an argument," >&2
                echo "or set IGV_JDK_REPO." >&2
                exit 1
              }
            fi

            igv_dir="$jdk_repo/src/utils/IdealGraphVisualizer"
            if [ ! -f "$igv_dir/igv.sh" ]; then
              echo "IGV launcher not found: $igv_dir/igv.sh" >&2
              exit 1
            fi

            export JAVA_HOME="''${JAVA_HOME:-${pkgs.jdk25}}"

            cd "$igv_dir"
            exec sh ./igv.sh
          '';
        };
      in
      {
        packages = {
          inherit igv;
          default = igv;
        };

        apps = {
          igv = flake-utils.lib.mkApp { drv = igv; };
          default = flake-utils.lib.mkApp { drv = igv; };
        };

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.bashInteractive
            pkgs.jdk25 # boot jdk
            pkgs.ant
            pkgs.autoconf
            pkgs.bash
            pkgs.zip
            pkgs.unzip
            pkgs.alsa-lib
            pkgs.cups
            pkgs.fontconfig
            pkgs.freetype # needed??
            pkgs.cpio
            pkgs.file
            pkgs.which
            pkgs.perl
            pkgs.zlib
            pkgs.libjpeg
            pkgs.giflib
            pkgs.libpng
            pkgs.xorg.libX11
            pkgs.xorg.libICE
            pkgs.xorg.libXrender
            pkgs.xorg.libXext
            pkgs.xorg.libXt
            pkgs.xorg.libXtst
            pkgs.xorg.libXi
            pkgs.xorg.libXinerama
            pkgs.xorg.libXcursor
            pkgs.xorg.libXrandr

            pkgs.maven # IGV
            igv
          ];
          env.NIX_CFLAGS_COMPILE = "-Wno-error -Wno-format-security";
          env.SOURCE_DATE_EPOCH = "946684800";
          shellHook = ''
            export ANT_HOME=$(dirname $(dirname $(command -v ant)))/lib/ant/
          '';
        };
      }
    );
}
