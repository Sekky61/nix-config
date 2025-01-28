{
  config,
  lib,
  hostname,
  ...
}:
with lib; let
  myServiceOptions = serviceName:
    with lib; {
      enable = mkEnableOption "the ${serviceName} service"; # Prefixes "Whether to enable "

      port = mkOption {
        type = types.ints.u16;
        description = ''
          The port to run ${serviceName} on
        '';
      };

      proxy = mkEnableOption "proxying of the service from port 80 under subdomain";

      subdomain = mkOption {
        type = types.str;
        description = ''
          The subdomain to expose ${serviceName} on
        '';
      };

      # TODO: always import all options, todo proxy settings
    };
in {
  imports =
    []
    ++ [
      # Proxy all services
      ./service_proxy.nix

      # The Services
      ./adguardhome.nix
      ./home-assistant.nix
      ./homepage.nix
    ];

  # Add my generic options to lib
  _module.args = {
    inherit myServiceOptions;
  };
}
