{
  pkgs,
  username,
  ...
}: {
  # Debugging and performance analysis tools

  # packages for development
  environment.systemPackages = with pkgs; [
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
    pkgs.linuxPackages_latest.perf
    hotspot
    poop # todo old version
  ];

  programs.bcc.enable = true; # Dynamic Tracing Tools for Linux

  # allow perf as user
  boot.kernel.sysctl."kernel.perf_event_paranoid" = -1;
}
