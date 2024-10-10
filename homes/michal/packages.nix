{pkgs, ...}: {
  home = {
    packages = with pkgs;
    with nodePackages_latest;
    with libsForQt5; [
      i3 # gaming
      sway
      nautilus-python

      # gui
      blueberry # Bluetooth gui
      d-spy
      kolourpaint
      nautilus
      icon-library
      dconf-editor
      qt5.qtimageformats
      vlc
      yad # Dialogs

      # tools
      bat
      eza
      gh # github cli
      fd
      ripgrep
      fzf
      socat
      jq
      gojq
      blender-hip
      acpi # battery info
      ffmpeg
      libnotify
      killall
      zip
      unzip
      glib
      foot
      kitty
      showmethekey # show pressed keys
      vscode
      ydotool
      nmap
      openssl_3_3
      lsof
      lazygit
      nixos-generators

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
      slurp
      swww
      wayshot
      wlsunset
      wl-clipboard
      wf-recorder
      iio-sensor-proxy # pc sensors
      libinput # wayland input settings
      libinput-gestures

      # michal
      xwayland # apps that do not work with wayland like spotify rn
      ripgrep
      bat
      zoxide
      xorg.xev
      spotify
      unrar
      vim
      htop
      powertop
      hwinfo
      rnote # drawing app for stylus
      ytdownloader
      wineWowPackages.waylandFull
      winetricks
      lutris
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
      gnumake
      cmake
      alejandra # nix formatter
      # very important stuff
      # uwuify
    ];
  };

  programs.neovim = {
    enable = true;
  };
}
