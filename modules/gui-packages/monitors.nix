{lib, ...}:
with lib; let
  # Run `hyprctl monitors` to find out
  monitorModule = types.submodule {
    options = {
      id = mkOption {
        type = types.str;
        description = "Monitor identifier (e.g., 'Samsung Display Corp. 0x4193')";
        example = "Samsung Display Corp. 0x4193";
      };

      width = mkOption {
        type = types.int;
        description = "Monitor width in pixels";
        example = 1920;
      };

      height = mkOption {
        type = types.int;
        description = "Monitor height in pixels";
        example = 1080;
      };

      refreshRate = mkOption {
        type = types.either types.int types.float;
        description = "Monitor refresh rate in Hz";
        example = 60.0;
      };

      position = mkOption {
        type = types.submodule {
          options = {
            x = mkOption {
              type = types.int;
              default = 0;
              description = "X position";
            };
            y = mkOption {
              type = types.int;
              default = 0;
              description = "Y position";
            };
          };
        };
        default = {
          x = 0;
          y = 0;
        };
        description = "Monitor position";
      };

      scale = mkOption {
        type = types.either (types.either types.int types.float) types.str;
        default = 1;
        description = "Monitor scale factor (or 'auto')";
        example = 1.5;
      };

      transform = mkOption {
        type = types.int;
        default = 0;
        description = "Monitor transform (0=normal, 1=90°, 2=180°, 3=270°)";
      };

      enabled = mkOption {
        type = types.bool;
        default = true;
        description = "Whether this monitor is enabled";
      };
    };
  };
in {
  options.michal.monitors = mkOption {
    type = types.listOf monitorModule;
    default = [];
    description = "List of monitor configurations";
    example = literalExpression ''
      [
        {
          id = "Samsung Display Corp. 0x4193";
          width = 2880;
          height = 1800;
          refreshRate = 90.0;
          position = { x = 0; y = 0; };
          scale = 1.5;
          transform = 0;
        }
        {
          id = "Gigabyte Technology Co. Ltd. G27QC A";
          width = 1920;
          height = 1080;
          refreshRate = 165.0;
          position = { x = 1920; y = 0; };
          scale = 1;
          transform = 0;
        }
      ]
    '';
  };
}
