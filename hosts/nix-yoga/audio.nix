{username, ...}: {
  # Audio
  hardware.pulseaudio.enable = false;
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

  security = {
    rtkit.enable = true; # related to sound
  };

  programs.dconf.enable = true; # Needed for easyeffects

  home-manager.users.${username} = _: {
    services.easyeffects.enable = true;
  };
}
