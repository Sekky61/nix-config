{
  lib,
  pkgs,
  config,
  username,
  ...
}:
with lib; let
  cfg = config.michal.programs.safe-chain;
  dev_cfg = config.michal.dev;

  startupScripts =
    if cfg.includePython
    then "${cfg.package}/share/safe-chain/startup-scripts/include-python"
    else "${cfg.package}/share/safe-chain/startup-scripts";

  jsTools = [
    {
      tool = "npm";
      aikidoCommand = "aikido-npm";
    }
    {
      tool = "npx";
      aikidoCommand = "aikido-npx";
    }
    {
      tool = "yarn";
      aikidoCommand = "aikido-yarn";
    }
    {
      tool = "pnpm";
      aikidoCommand = "aikido-pnpm";
    }
    {
      tool = "pnpx";
      aikidoCommand = "aikido-pnpx";
    }
    {
      tool = "rush";
      aikidoCommand = "aikido-rush";
    }
    {
      tool = "rushx";
      aikidoCommand = "aikido-rushx";
    }
    {
      tool = "bun";
      aikidoCommand = "aikido-bun";
    }
    {
      tool = "bunx";
      aikidoCommand = "aikido-bunx";
    }
  ];

  pythonTools = [
    {
      tool = "uv";
      aikidoCommand = "aikido-uv";
    }
    {
      tool = "uvx";
      aikidoCommand = "aikido-uvx";
    }
    {
      tool = "pip";
      aikidoCommand = "aikido-pip";
    }
    {
      tool = "pip3";
      aikidoCommand = "aikido-pip3";
    }
    {
      tool = "python";
      aikidoCommand = "aikido-python";
    }
    {
      tool = "python3";
      aikidoCommand = "aikido-python3";
    }
    {
      tool = "poetry";
      aikidoCommand = "aikido-poetry";
    }
    {
      tool = "pipx";
      aikidoCommand = "aikido-pipx";
    }
    {
      tool = "pdm";
      aikidoCommand = "aikido-pdm";
    }
  ];

  tools = jsTools ++ optionals cfg.includePython pythonTools;

  shimFiles = listToAttrs (map ({tool, ...}:
    nameValuePair ".safe-chain/shims/${tool}" {
      executable = true;
      text = ''
        #!/bin/sh
        remove_shim_from_path() {
          old_ifs=$IFS
          IFS=:
          new_path=
          for entry in $PATH; do
            if [ "$entry" = "$HOME/.safe-chain/shims" ]; then
              continue
            fi

            if [ -z "$new_path" ]; then
              new_path=$entry
            else
              new_path=$new_path:$entry
            fi
          done
          IFS=$old_ifs
          printf '%s\n' "$new_path"
        }

        PATH=$(remove_shim_from_path)
        export PATH
        unset PKG_EXECPATH
        exec ${cfg.package}/bin/safe-chain ${tool} "$@"
      '';
    })
  tools);

  pathShimPosixInit = ''
    _safe_chain_run_shim() {
      original_cmd=$1
      shift
      shim="$HOME/.safe-chain/shims/$original_cmd"

      if [ -x "$shim" ]; then
        "$shim" "$@"
      else
        command "$original_cmd" "$@"
      fi
    }

    ${concatMapStringsSep "\n" ({tool, ...}: ''
        ${tool}() {
          _safe_chain_run_shim ${tool} "$@"
        }
      '')
      tools}
  '';

  pathShimFishInit = ''
    function __safe_chain_run_shim
        set -l original_cmd $argv[1]
        set -e argv[1]
        set -l shim "$HOME/.safe-chain/shims/$original_cmd"

        if test -x "$shim"
            command "$shim" $argv
        else
            command "$original_cmd" $argv
        end
    end

    ${concatMapStringsSep "\n" ({tool, ...}: ''
        function ${tool}
            __safe_chain_run_shim ${tool} $argv
        end
      '')
      tools}
  '';
in {
  options.michal.programs.safe-chain = {
    enable = mkEnableOption "Aikido Safe Chain";

    package = mkOption {
      type = types.package;
      default = pkgs.safe-chain or (pkgs.callPackage ../../pkgs/safe-chain {});
      description = "Safe Chain package to install.";
    };

    includePython = mkOption {
      type = types.bool;
      default = true;
      description = "Also wrap pip, pip3, python -m pip, and python3 -m pip.";
    };

    integration = mkOption {
      type = types.enum ["shell" "pathShims"];
      default = "shell";
      description = "How to integrate Safe Chain. pathShims also installs shell dispatchers so dev shells cannot shadow the shims.";
    };
  };

  config = mkMerge [
    (mkIf dev_cfg.enable {
      michal.programs.safe-chain.enable = mkDefault true;
    })

    (mkIf cfg.enable {
      programs.bash.interactiveShellInit = ''
        source "$HOME/.safe-chain/scripts/init-posix.sh"
      '';

      home-manager.users.${username} = {
        home = {
          packages = [cfg.package];

          file =
            {
              ".safe-chain/scripts/init-posix.sh" =
                {
                  force = true;
                }
                // (
                  if cfg.integration == "shell"
                  then {source = "${startupScripts}/init-posix.sh";}
                  else {text = pathShimPosixInit;}
                );

              ".safe-chain/scripts/init-fish.fish" =
                {
                  force = true;
                }
                // (
                  if cfg.integration == "shell"
                  then {source = "${startupScripts}/init-fish.fish";}
                  else {text = pathShimFishInit;}
                );
            }
            // optionalAttrs (cfg.integration == "pathShims") shimFiles;

          sessionPath = optionals (cfg.integration == "pathShims") [
            "$HOME/.safe-chain/shims"
          ];
        };

        xdg.configFile."fish/conf.d/safe-chain.fish" = {
          text = ''
            source "$HOME/.safe-chain/scripts/init-fish.fish"
          '';
        };
      };
    })
  ];
}
