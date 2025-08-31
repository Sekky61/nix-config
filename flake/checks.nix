{
  self,
  inputs,
  ...
}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    checks = let
      # I dont like that it has to produce output and create a result/ in my project
      fmt-check =
        pkgs.runCommandLocal "fmt-check" {
          src = self;
          nativeBuildInputs = with pkgs; [alejandra];
        } ''
          alejandra -c .
          mkdir "$out"
        '';

      deploy-checks = (builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib).${system};
    in
      {
        inherit fmt-check;
      }
      // deploy-checks;
  };
}
