{
  config,
  pkgs,
  lib,
  username,
  ...
}:
with lib; let
  # On first run, you may need to ssh into the borgbase to add it to known hosts
  # Backed up at: https://www.borgbase.com
  # The first time can take a lot of time. Be more patient than I was ☮️
  #
  # Sources:
  # - https://xeiaso.net/blog/borg-backup-2021-01-09/
  # TODO: integrate to dashboard (healthcheck)
  # TODO: might be more suitable to configure this per-host
  cfg = config.michal.programs.borg;
  borgbase = "u6ddiz7x@u6ddiz7x.repo.borgbase.com";
in {
  options.michal.programs.borg = {
    enable = mkEnableOption "borg backups to borgbase";

    common-exclude-patterns = mkOption {
      type = with types; listOf str;
      default = [
        # Shell-style patterns, selector sh:
        "sh:**/venv/"
        "sh:**/.venv/"
        "*.pyc"
        "/home/*/.cache"
        "**/[Cc]ache*"
        # Programs that store too-big stuff under .config
        "/home/samh/.config/Code" # stores cache here 🤮
        "/home/samh/.config/vivaldi-backup"
        "/home/samh/.config/syncthing*"
        # Chromium profile junk
        "/home/samh/.config/chromium/hyphen-data"
        "/home/samh/.config/chromium/OnDeviceHeadSuggestModel"
        "/home/samh/.config/chromium/**/*Cache"
        # Firefox profile junk
        "**/datareporting"
        "**/safebrowsing"
        # Games
        "/home/*/.local/share/Steam/*"
        "/home/*/Games/*"
        "/home/*/Downloads/*"
        "/home/*/.local/share/lutris"
        "/home/*/.wine"
        # Development
        "/home/*/**/node_modules"
        "/home/*/**/target/*"
        "/home/*/.arduino*/packages"
        "/home/*/.arduino*/staging"
        "/home/*/.cargo"
        "/home/*/.local/share/docker"
        "/home/*/.local/share/godot"
        "/home/*/.local/share/nvim"
        "/home/*/.local/share/pnpm"
        "/home/*/.npm"
        "/home/*/.rustup/toolchains"
        "/home/*/go/bin"
        "/home/*/go/pkg"
        "/home/*/_mesonbuild"
        "/home/*/zig-out"
        "/home/*/.zig-cache"
        # Others
        "/home/*/**/*t[e]?mp*"
        "/home/*/.local/share/Trash"
      ];
    };
  };

  config = mkIf cfg.enable {
    services.borgbackup.jobs."borgbase" = {
      paths = [
        "/home/${username}/Documents"
      ];
      exclude =
        cfg.common-exclude-patterns
        ++ [
          "/home/*/Documents/vms" # VMs too big
        ];
      repo = "ssh://${borgbase}/./repo";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${config.sops.secrets."borg-backup/passphrase".path}";
      };
      extraArgs = "--verbose --progress";
      environment.BORG_RSH = "ssh -i ${config.sops.secrets."borg-backup/key".path}";
      compression = "auto,lzma";
      startAt = "hourly";

      prune.keep = {
        daily = 7;
        weekly = 4;
        monthly = -1; # Keep at least one archive for each month
      };
    };
  };
}
