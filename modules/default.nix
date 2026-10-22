{
  pkgs,
  inputs,
  config,
  ...
}: {
  # TODO added 2026-10-22; estimate: next nixpkgs refresh, likely days to weeks.
  # Remove once locked cacert/NSS includes the distrust update; recheck both test hosts first.
  # Block the two roots used by the compromised eMudhra intermediates.
  # Browser revocation lists do not cover system TLS clients such as curl/OpenSSL.
  security.pki.caCertificateBlacklist = [
    "Comodo AAA Services root"
    "emSign ECC Root CA - G3"
  ];

  imports = [
    # Truly common, always there
    ./btop.nix
    ./ssh.nix
    ./sops
    ./nix-config.nix
    ./cachix.nix
    ./locale.nix
    ./packages # admin/debug packages
    ./js-binfmt.nix
    ./overlays
    ./xdg.nix
    ./nvim
    ./bash
    ./terminal.nix

    # Modules with options
    ../assets
    ./audio.nix
    ./battery.nix
    ./network
    ./system/docker.nix
    ./system/podman.nix
    ./dev
    ./gui-packages
    ./bitwarden.nix
    ./aikido-endpoint-protection.nix
    ./ventoy.nix
    ./borg.nix
    ./ollama.nix
    ./theme
    ./impurity.nix
    ./gamedev
    ./waybar
    ./hyprland
  ];

  environment.systemPackages = with pkgs; [
    nix-output-monitor # pretty nixos-switch
  ];
}
