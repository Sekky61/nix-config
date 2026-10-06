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
      pkgs.lib.optionalAttrs (pkgs.stdenvNoCC.hostPlatform.isLinux) (let
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

        nixpi-sd-image =
          (self.nixosConfigurations.nixpi.extendModules {
            modules = [
              "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
              {sdImage.firmwareSize = 256;}
            ];
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
