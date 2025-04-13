{self, ...}: {
  perSystem = {pkgs, ...}: {
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
    in {
      inherit fmt-check;
    };
  };
}
