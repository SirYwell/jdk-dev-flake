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
      in
      {
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
