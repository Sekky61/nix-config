{
  imports = [
    ./audio.nix
    ./gnome.nix
    ./hardware-configuration.nix
    ./configuration.nix
    ./laptop.nix
    ./locale.nix
  ];

  michal.programs = {
    bitwarden.enable = true;
  };
}
