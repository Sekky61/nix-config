{
  perSystem = {pkgs, ...}: {
    # Runs on save in nvim or with `nix fmt`
    formatter = pkgs.alejandra;
  };
}
