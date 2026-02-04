{
  specialArgs,
  inputs,
  self,
  ...
}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    packages =
      pkgs.lib.optionalAttrs (pkgs.stdenvNoCC.isLinux) (let
        # https://github.com/NixOS/nixpkgs/tree/master/nixos/modules/installer/sd-card
        rpiSdCard = "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix";
        # # https://github.com/NixOS/nixpkgs/issues/126755#issuecomment-869149243
        missingKernelModulesFix = {
          nixpkgs.overlays = [
            (final: prev: {
              makeModulesClosure = x:
                prev.makeModulesClosure (x // {allowMissing = true;});
            })
          ];
        };
        modules = [rpiSdCard missingKernelModulesFix];

        # todo move
        mkLib = nixpkgs:
          nixpkgs.lib.extend (final: prev:
            (import ../modules/lib.nix final) // inputs.home-manager.lib);

        lib = mkLib inputs.nixpkgs;
      in {
        minimal-iso =
          import ./../pkgs/installer-iso {inherit pkgs system specialArgs;};
        nix-yoga-live =
          import ./../pkgs/nix-yoga-live.nix {inherit inputs self lib;};

        # minimal-pi-sd-image =
        #   (self.nixosConfigurations.minimal-pi.extendModules {inherit modules;}).config.system.build.sdImage;

        nixpi-sd-image =
          (self.nixosConfigurations.nixpi.extendModules {
            inherit modules;
          }).config.system.build.sdImage;

        nvim = pkgs.stdenv.mkDerivation {
          pname = "nvim-wrapper";
          version = "1.0";

          src = ../modules/nvim; # assumes init.lua

          buildInputs = [pkgs.makeWrapper pkgs.neovim];

          installPhase = ''
            mkdir -p $out/bin
            makeWrapper ${pkgs.neovim}/bin/nvim $out/bin/nvim \
              --add-flags "-u $src/init.lua"
          '';
        };

        michal-options-docs =
          pkgs.callPackage ../generate-docs.nix {inherit inputs;};
      })
      // {
        nix-yoga-vm =
          self.nixosConfigurations.nix-yoga.config.system.build.vmWithBootLoader;
      };
  };
}
