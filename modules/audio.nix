{ config, pkgs, lib, ... }:
with lib;
let cfg = config.michal.audio;
in {
  options.michal.audio = {
    enable = mkEnableOption "audio subsystem (PipeWire + utilities)";

    guiTools = mkOption {
      type = types.bool;
      default = true;
      description = "Install GUI audio tools (pavucontrol, qpwgraph, helvum)";
    };
  };

  config = mkIf cfg.enable {
    services.pipewire = {
      enable = true;
      audio.enable = true;
      jack.enable = true;
      pulse.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
    };

    security.rtkit.enable = true;
    programs.dconf.enable = true;

    environment.systemPackages = with pkgs;
      [ ] ++ lib.lists.optionals cfg.guiTools [
        pavucontrol
        qpwgraph
        helvum
        pulseaudio
        pulsemixer
      ];
  };
}
