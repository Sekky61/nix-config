{ pkgs, ... }:
{

  home = {
    packages = with pkgs; with nodePackages_latest; with gnome; with libsForQt5; [
      i3 # gaming
      sway

      # gui
      blueberry
      (mpv.override { scripts = [ mpvScripts.mpris ]; })
      d-spy
      dolphin
      kolourpaint
      github-desktop
      nautilus
      icon-library
      dconf-editor
      qt5.qtimageformats
      vlc
      yad

      # tools
      bat
      eza
      fd
      ripgrep
      fzf
      socat
      jq
      gojq
      acpi
      ffmpeg
      libnotify
      killall
      zip
      unzip
      glib
      foot
      kitty
      starship
      showmethekey
      vscode
      ydotool

      # theming tools
      gradience
      gnome-tweaks

      # hyprland
      brightnessctl
      cliphist
      fuzzel
      bemoji # emoji picker
      grim
      hyprpicker
      tesseract
      imagemagick
      pavucontrol
      playerctl
      swappy
      swaylock-effects
      swayidle
      slurp
      swww
      wayshot
      wlsunset
      wl-clipboard
      wf-recorder

      # michal
      xwayland # apps that do not work with wayland like spotify rn
      ripgrep
      bat
      zoxide
      xorg.xev
      google-chrome
      spotify
      vim
      htop
      powertop
      hwinfo
      rnote # drawing app for stylus
      obs-studio
      ytdownloader
      # dev tools
      insomnia
      wireshark

      # Small tools Michal
      exif # read metadata of pictures
      file

      # langs
      nodejs
      gjs
      bun
      cargo
      go
      gcc
      typescript
      eslint
      lua
      zig
      # very important stuff
      # uwuify
    ];
  };

  programs.neovim = {
    enable = true;
  };



}
