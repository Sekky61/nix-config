{
  # Audio
  hardware.pulseaudio.enable = false;
  hardware.alsa.enablePersistence = true;
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
}
