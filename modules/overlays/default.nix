{
  config,
  pkgs,
  lib,
  ...
}: {
  # Source:
  # - https://nixos-and-flakes.thiscute.world/nixpkgs/overlays
  # - https://nixos-and-flakes.thiscute.world/nixos-with-flakes/downgrade-or-upgrade-packages

  nixpkgs.overlays = [
    # # Example:
    # (final: prev: {
    #   steam = prev.steam.override {
    #     extraPkgs = pkgs: with pkgs; [
    #       keyutils
    #       libkrb5
    #       libpng
    #       libpulseaudio
    #       libvorbis
    #       stdenv.cc.cc.lib
    #       xorg.libXcursor
    #       xorg.libXi
    #       xorg.libXinerama
    #       xorg.libXScrnSaver
    #     ];
    #     extraProfile = "export GDK_SCALE=2";
    #   };
    # })
    # (import ./overlay3)
  ];
}
