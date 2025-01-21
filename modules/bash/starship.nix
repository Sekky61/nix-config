{
  lib,
  hostname,
  config,
  ...
}:
let
  lang = icon: color: {
    symbol = icon;
    format = "[$symbol $version](${color})";
  };
  os = icon: fg: "[${icon} ](fg:${osColor fg})";
  pad = {
    left = "";
    right = "";
  };

  # username and hostname based color
  host_colors = {
    nix-yoga = "green";
    nixpi = "red";
  };

  theme = config.michal.theme;

  osColor =
    fallback: if builtins.hasAttr hostname host_colors then host_colors.${hostname} else fallback;
in
{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      format = lib.strings.concatStrings [
        "$os"
        "$nix_shell"
        "$directory"
        "$container"
        "$direnv"
        "$git_branch $git_status"
        "$python"
        "$nodejs"
        "$lua"
        "$rust"
        "$java"
        "$c"
        "$zig"
        "$golang"
        "$cmd_duration"
        "$status"
        "$line_break"
        "[❯](bold purple)"
        ''''${custom.space}''
      ];
      custom.space = {
        when = ''! test $env'';
        format = "  ";
      };
      continuation_prompt = "∙  ┆ ";
      line_break = {
        disabled = false;
      };
      status = {
        symbol = "✗";
        not_found_symbol = "󰍉 Not Found";
        not_executable_symbol = " Can't Execute E";
        sigint_symbol = "󰂭 ";
        signal_symbol = "󱑽 ";
        success_symbol = "";
        format = "[$symbol](fg:${theme.error})";
        map_symbol = true;
        disabled = false;
      };
      git_state = {
        format = "[\($state( $progress_current of $progress_total)\)]($style) ";
        cherry_pick = "[🍒 PICKING](bold red)";
      };
      cmd_duration = {
        min_time = 300;
        format = "[$duration ](fg:yellow)";
      };
      nix_shell = {
        disabled = false;
        format = "[${pad.left}](fg:${theme.tertiary})[ ](bg:${theme.tertiary} fg:${theme.onTertiary})[${pad.right}](fg:${theme.tertiary}) ";
      };
      container = {
        symbol = " 󰏖";
        format = "[$symbol ](yellow dimmed)";
      };
      directory = {
        format = " [${pad.left}](fg:${theme.primary})[$path](bg:${theme.primary} bold fg:${theme.onPrimary})[${pad.right}](fg:${theme.primary}) ";
        truncation_length = 6;
        truncation_symbol = "~/󰇘/";
      };
      directory.substitutions = {
        "Documents" = "󰈙 ";
        "Downloads" = " ";
        "Music" = " ";
        "Pictures" = " ";
        "Videos" = " ";
        "Projects" = "󱌢 ";
        "School" = "󰑴 ";
        ".config" = " ";
        "Vault" = "󱉽 ";
        "hyprland" = "  ";
        "GitHub" = "  ";
      };
      git_branch = {
        symbol = "";
        style = "";
        format = "[ $symbol $branch](fg:purple)(:$remote_branch)";
      };
      os = {
        disabled = false;
        format = "$symbol";
      };
      os.symbols = {
        Arch = os "" "bright-blue";
        Debian = os "" "red)";
        EndeavourOS = os "" "purple";
        Fedora = os "" "blue";
        NixOS = os "" hostname;
        openSUSE = os "" "green";
        SUSE = os "" "green";
        Ubuntu = os "" "bright-purple";
      };
      direnv = { 
        disabled = false;
        format = "[${pad.left}](fg:${theme.secondary})[$symbol $loaded](bg:${theme.secondary} bold fg:${theme.onSecondary})[${pad.right}](fg:${theme.secondary}) ";
        symbol = "";
        loaded_msg = "󰄬";
        unloaded_msg = "";
      };
      python = lang "" "yellow";
      nodejs = lang " " "yellow";
      lua = lang "󰢱" "blue";
      rust = lang "" "red";
      java = lang "" "red";
      c = lang "" "blue";
      golang = lang "" "blue";
      zig = lang "" "bold yellow" // {
        detect_files = [ "build.zig" ];
        detect_folders = [ ".zig-cache" ];
      };
      nix = lang "󱄅" "blue";
    };
  };
}
