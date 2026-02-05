{
  pkgs,
  inputs,
  ...
}: let
  lib = pkgs.lib;

  eval = lib.evalModules {
    modules = [
      (pkgs.path + "/nixos/modules/misc/lib.nix")
      ({lib, ...}: {
        config._module.check = false;

        # options.michal.theme = lib.mkOption {
        #   type = with lib.types; attrsOf str;
        #   default = { };
        #   description = ''
        #     Keyed colors. Assume #RRGGBB. Names like primary, surface.
        #   '';
        #   example = {
        #     primary = "#8dcdff";
        #     outline = "#8b9198";
        #     error = "#ffb4a9";
        #   };
        # };

        options.programs = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = {};
          description = "Stub programs namespace for docs generation.";
        };
      })
      ({lib, ...}: {config.stylix.overlays.enable = lib.mkForce false;})
      ./modules
      ./services/default.nix
    ];
    specialArgs = {
      inherit inputs pkgs;
      username = "docs";
      hostname = "docs";
    };
  };

  # Output shape: options.json is a map of option names to metadata.
  # Example keys: declarations, default (literalExpression), description, example,
  # loc (path list), readOnly, type.
  docs = pkgs.nixosOptionsDoc {
    options = eval.options;
    warningsAreErrors = false;
  };
in
  pkgs.runCommand "michal-options-docs" {} ''
    mkdir -p "$out"
    cp ${docs.optionsJSON}/share/doc/nixos/options.json "$out/options.json"
  ''
