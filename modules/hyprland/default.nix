{
  config,
  pkgs,
  lib,
  username,
  ...
}:
with lib; let
  cfg = config.michal.hyprland;
  browser = config.environment.sessionVariables.BROWSER;
  defaultTerminal = config.michal.environment.terminal;
  monitors = config.michal.monitors;
  walkerBin = "${pkgs.walker}/bin/walker";

  toLua = lib.generators.toLua {};
  monitorToLua = monitor:
    if monitor.enabled
    then ''
      hl.monitor({
        output = "desc:${monitor.id}",
        mode = "${toString monitor.width}x${toString monitor.height}@${toString monitor.refreshRate}",
        position = "${toString monitor.position.x}x${toString monitor.position.y}",
        scale = ${toLua monitor.scale},
        transform = ${toLua monitor.transform},
      })
    ''
    else ''
      hl.monitor({
        output = "desc:${monitor.id}",
        disabled = true,
      })
    '';
in {
  imports = [
    ./keybinds.nix
    ./hyprland_keybinds.nix
    ./gromit.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./auth.nix
  ];

  options.michal.hyprland = {
    enable = mkEnableOption "Hyprland desktop configuration";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # launcher

      # todo broken
      #nwg-displays # gui for monitors, wayland
      hyprshot

      grim
      slurp
      hyprpicker # color picker

      # hyprland
      brightnessctl
      cliphist # clipboard history
      tesseract # OCR
      imagemagick
      pavucontrol
      playerctl
      swappy
      awww # wallpaper
      wayshot
      wlsunset
      wl-clipboard
      libinput # wayland input settings
      libinput-gestures
      xwayland # apps that do not work with wayland like spotify rn
      nwg-displays # GUI for resolution and monitor placement
    ];

    programs.hyprland.enable = true; # enables xdg-desktop-portal-hyprland

    programs.xwayland.enable = true;

    programs.iio-hyprland.enable = true; # screen rotation, todo does not work

    home-manager.users.${username} = {
      # Optional, hint Electron apps to use Wayland:
      home.sessionVariables.NIXOS_OZONE_WL = "1";

      xdg.desktopEntries."org.gnome.Settings" = {
        name = "Settings";
        comment = "Gnome Control Center";
        icon = "org.gnome.Settings";
        exec = "env XDG_CURRENT_DESKTOP=gnome ${pkgs.gnome-control-center}/bin/gnome-control-center";
        categories = ["X-Preferences"];
        terminal = false;
      };

      wayland.windowManager.hyprland = {
        enable = true;
        configType = "lua";

        # Home Manager's systemd integration is emitted into its generated
        # hyprland.lua. The linked entrypoint starts hyprland-session.target
        # directly so this file can stay owned by the repo.
        systemd.enable = false;

        settings = mkForce {};

        plugins = with pkgs; [
          # hyprlandPlugins.<plugin>
        ];

        # Hyprland 0.55+ uses Lua config. Keep the active config in
        # hyprland.lua instead of generated Nix settings while migrating.
        extraConfig = mkForce "";
      };

      xdg.configFile."hypr/hyprland.lua".source = ./hyprland.lua;
      xdg.configFile."hypr/hypr".source = ./lua;
      xdg.configFile."hypr/generated/startup.lua".text = ''
        -- Generated from default session applications.
        hl.on("hyprland.start", function()
          hl.exec_cmd(${toLua browser}, { workspace = "1 silent" })
          hl.exec_cmd(${toLua defaultTerminal}, { workspace = "2 silent" })
        end)
      '';
      xdg.configFile."hypr/generated/rules.lua".text = ''
        -- Generated from optional Hyprland integrations.
        ${optionalString config.michal.programs.walker.enable ''
          hl.gesture({
            fingers = 4,
            direction = "down",
            action = function()
              hl.exec_cmd(${toLua walkerBin})
            end,
          })
        ''}
      '';
      xdg.configFile."hypr/generated/monitors.lua".text = ''
        -- Generated from config.michal.monitors.
        ${concatStringsSep "\n" (map monitorToLua monitors)}

        hl.monitor({
          output = "",
          mode = "preferred",
          position = "auto",
          scale = "auto",
        })
      '';
    };
  };
}
