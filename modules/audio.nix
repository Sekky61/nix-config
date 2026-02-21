{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.michal.audio;
  nextTrackCmd = "playerctl next || playerctl position `bc <<< '100 * $(playerctl metadata mpris:length) / 1000000 / 100'`";
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
      []
      ++ lib.lists.optionals cfg.guiTools [
        pavucontrol
        qpwgraph
        helvum
        pulseaudio
        pulsemixer
      ];

    michal.programs.hyprland.keybinds =
      [
        {
          description = "Set volume to 0%";
          bind = {
            mods = [];
            key = "XF86AudioMute";
          };
          command = {
            params = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0%";
            flags = ["locked"];
          };
        }
        {
          description = "Set volume to 0%";
          bind = {
            mods = ["SUPER" "SHIFT"];
            key = "M";
          };
          command = {
            params = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0%";
            flags = ["locked"];
          };
        }
        {
          description = "Play next track or move to 100% position";
          bind = {
            mods = ["SUPER" "SHIFT"];
            key = "N";
          };
          command = {
            params = nextTrackCmd;
            flags = ["locked"];
          };
        }
        {
          description = "Play next track or move to 100% position";
          bind = {
            mods = [];
            key = "XF86AudioNext";
          };
          command = {
            params = nextTrackCmd;
            flags = ["locked"];
          };
        }
        {
          description = "Play previous track";
          bind = {
            mods = ["SUPER" "SHIFT"];
            key = "B";
          };
          command = {
            params = "playerctl previous";
            flags = ["locked"];
          };
        }
        {
          description = "Play/pause media";
          bind = {
            mods = ["SUPER" "SHIFT"];
            key = "P";
          };
          command = {
            params = "playerctl play-pause";
            flags = ["locked"];
          };
        }
        {
          description = "Play/pause media";
          bind = {
            mods = [];
            key = "XF86AudioPlay";
          };
          command = {
            params = "playerctl play-pause";
            flags = ["locked"];
          };
        }
        {
          description = "Raise volume";
          bind = {key = "XF86AudioRaiseVolume";};
          command = {
            params = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+";
            flags = ["repeat"];
          };
        }
        {
          description = "Lower volume";
          bind = {key = "XF86AudioLowerVolume";};
          command = {
            params = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
            flags = ["repeat"];
          };
        }
      ]
      ++ optionals cfg.guiTools [
        {
          description = "Open volume control";
          bind = {
            mods = ["CONTROL" "SUPER"];
            key = "V";
          };
          command = {params = "pavucontrol";};
        }
      ];
  };
}
