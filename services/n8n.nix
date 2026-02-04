{
  config,
  lib,
  hostname,
  myServiceOptions,
  ...
}:
with lib; let
  cfg = config.michal.services.n8n;
in {
  options.michal.services.n8n = myServiceOptions "n8n";

  config = mkIf cfg.enable {
    services.n8n = {
      enable = true;
      environment = {
        N8N_PORT = toString cfg.port;
      };
      openFirewall = true;
    };
  };
}
