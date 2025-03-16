{pkgs, ...}: {
  # dependencies for stt script
  environment.systemPackages = with pkgs; [
    sox
    ydotool
    whisper-cpp
    screen
    curl
  ];
}
