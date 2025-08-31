{inputs, ...}: {
  perSystem = {
    system,
    pkgs,
    ...
  }: {
    devShells = {
      default = let
        check = pkgs.writeShellScriptBin "check" ''
          ${pkgs.nix-fast-build}/bin/nix-fast-build "$@"
        '';
      in
        pkgs.mkShell {
          name = "The devshell";
          meta.description = "Flake development environment";
          buildInputs = with pkgs; [
            alejandra
            statix
            nix-fast-build
            check
            # `deploy`
            # could be obtained with `inputs.deploy-rs.packages.${system}.default`
            # but this is cached. maybe the overlay could have helped
            deploy-rs
          ];
        };
    };
  };
}
