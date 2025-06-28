{pkgs, ...}: {
  # dependencies for stt script, todo move, make optional
  environment.systemPackages = with pkgs; [
    sox
    ydotool
    whisper-cpp
    screen
    curl
  ];
}
