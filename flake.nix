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
        jtreg = pkgs.callPackage ./jtreg.nix {
          inherit jtharness;
        };
        jtharness = pkgs.callPackage ./jtharness.nix { };
        asmtools = pkgs.callPackage ./asmtools.nix { };
      in
      {
        packages = {
          inherit igv jtreg jtharness asmtools;
          default = igv;
        };

        apps = {
          igv = flake-utils.lib.mkApp { drv = igv; };
          default = flake-utils.lib.mkApp { drv = igv; };
        };

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.bashInteractive
            pkgs.temurin-bin-26 # boot jdk
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
            pkgs.libX11
            pkgs.libice
            pkgs.libxrender
            pkgs.libxext
            pkgs.libxt
            pkgs.libxtst
            pkgs.libxi
            pkgs.libxinerama
            pkgs.libxcursor
            pkgs.libxrandr

            pkgs.maven # IGV
            igv
            jtreg
          ];
          env.NIX_CFLAGS_COMPILE = "-Wno-error -Wno-format-security";
          env.SOURCE_DATE_EPOCH = "946684800";
          env.JTREGEXE = jtreg;
          shellHook = ''
            export ANT_HOME=$(dirname $(dirname $(command -v ant)))/lib/ant/
          '';
        };
      }
    );
}
