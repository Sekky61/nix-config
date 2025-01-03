{
  specialArgs,
  inputs,
  self,
  ...
}:
{
  perSystem =
    { pkgs, ... }:
    {
      packages = pkgs.lib.optionalAttrs (pkgs.stdenvNoCC.isLinux) (
        let
          rpiSdCard = "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix";
          # # https://github.com/NixOS/nixpkgs/issues/126755#issuecomment-869149243
          missingKernelModulesFix = {
            nixpkgs.overlays = [
              (final: prev: { makeModulesClosure = x: prev.makeModulesClosure (x // { allowMissing = true; }); })
            ];
          };
          modules = [
            rpiSdCard
            missingKernelModulesFix
          ];
        in
        {
          minimal-iso = import ./../pkgs/installer-iso { inherit pkgs specialArgs; };
          rpi-sd-image =
            (self.nixosConfigurations.rpi.extendModules { inherit modules; }).config.system.build.sdImage;
        }
      );
    };
}
