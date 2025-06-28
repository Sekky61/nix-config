{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./ags
    ./stt.nix

    # With options
    ./fuzzel.nix
    ./fonts.nix
    ./options.nix
    ./remote-desktop.nix
    ./obs.nix
    ./kde-connect.nix
    ./browser
    ./steam.nix
    ./terminal-emulator
    ./apps.nix
  ];
}
