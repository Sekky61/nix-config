{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.michal.programs.stt;
in {
  options.michal.programs.stt = {
    enable = mkOption {
      type = types.bool;
      default = config.michal.graphical.enable;
      description = "speech-to-text tools";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      curl
      handy
      openwhispr
      screen
      sox
      ydotool
    ];
  };

  # Needs ydotool to be launched on startup

  # OpenWhispr stores UI settings in Electron LocalStorage LevelDB, not in a
  # normal text config file. Quit OpenWhispr before changing it, otherwise the
  # DB is locked.
  #
  # Config paths:
  # - ~/.config/open-whispr/.env
  # - ~/.config/open-whispr/secure-keys/
  # - ~/.config/open-whispr/Local Storage/leveldb/
  #
  # cleanupModel is stored in LevelDB under:
  #   _file://\0\1cleanupModel
  #
  # Example, using a Python environment with plyvel available:
  #   MODEL="anthropic/claude-sonnet-4" python3 - <<'PY'
  #   import os
  #   import plyvel
  #
  #   db = plyvel.DB(os.path.expanduser("~/.config/open-whispr/Local Storage/leveldb"), create_if_missing=False)
  #   db.put(b"_file://\x00\x01cleanupModel", b"\x01" + os.environ["MODEL"].encode())
  #   db.close()
  #   PY
}
