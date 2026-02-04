{
  lib,
  config,
  pkgs,
  username,
  ...
}:
with lib; let
  cfg = config.michal.dev;
in {
  config = mkIf cfg.enable {
    # Debugging and performance analysis tools

    # packages for development
    home-manager.users.${username} = {
      home.packages = with pkgs; [
        # Debugging
        gdb
        lldb_18
        strace
        valgrind
        rr # record and replay, both gdb and lldb

        gdbgui
        gf # another frontend

        # Perf
        perf-tools
        gperftools
        perf
        hotspot
        poop # todo old version
      ];

      programs.gemini-cli = {
        enable = true;
        # no settings - it forces gemini to auth every time
      };
    };

    programs.bcc.enable = true; # Dynamic Tracing Tools for Linux

    # allow perf as user
    boot.kernel.sysctl."kernel.perf_event_paranoid" = -1;
  };
}
