{
  username,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  # Defines all pubkeys
  cfg = config.michal.sshKeys;
  fetchKeys = s: builtins.readFile (builtins.fetchurl s);
  splitKeys = keys: splitString "\n" keys;
  filterLines = lines: filter (line: line != "" && !(hasPrefix "#" line)) lines;
in {
  options.michal.sshKeys = {
    personal = {
      remotes = mkOption {
        default = [];
        description = "urls and their sha256 that will be passed to fetchurl function";
        type = types.listOf (
          types.submodule {
            options = {
              url = mkOption {
                type = types.str;
                example = "https://github.com/Sekky61.keys";
              };
              sha256 = mkOption {
                type = types.str;
                example = "sha256:0i8s5nc48dpf1rvjnk22ny03ckvyk4mpydgd48g2wz687v8wip05";
              };
            };
          }
        );
      };
      extraKeys = mkOption {
        type = types.listOf types.str;
        example = ''[ "ssh-rsa abcd" ]'';
        default = [];
        description = "extra keys to be added";
      };
      keys = mkOption {
        type = types.listOf types.str;
        readOnly = true;
        description = "all keys";
      };
    };
    work = {
      keys = mkOption {
        type = types.attrsOf types.str;
        example = ''{ company="ssh-rsa abcd" }'';
        default = {};
        description = "company - key mapping to be added";
      };
    };
  };

  config = let
    contents = builtins.map fetchKeys cfg.personal.remotes;
    splits = flatten (builtins.map splitKeys contents);
    remoteKeys = filterLines splits;
  in {
    michal.sshKeys = {
      personal.keys = remoteKeys ++ cfg.personal.extraKeys;
      # todo: also keep the pubkeys around in a file
      personal.remotes = [
        {
          url = "https://github.com/Sekky61.keys";
          sha256 = "sha256:16mvisd872n4l68kbi76ra9mvr215rhrh2ll4pdga6d13fycpv4i";
        }
      ];
    };

    # This is different from home-manager.users
    users.users.${username} = {
      openssh.authorizedKeys.keys = cfg.personal.keys;
    };
    users.users.root = {
      openssh.authorizedKeys.keys = cfg.personal.keys;
    };

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
      settings.X11Forwarding = true;

      # AFAIK not that necessary
      #
      # knownHosts = {
      #   nixpi = {
      #     publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBimO7J9WOplF/P1YLgWfx5IFy9nGY+sBfn7xoAdY5hZ root@nixpi";
      #     hostNames = [ "nixpi-wifi" ];
      #   };
      # };
    };

    # Keychain section

    environment.systemPackages = with pkgs; [
      gnome-keyring
    ];

    services.gnome.gnome-keyring.enable = true;
  };
}
