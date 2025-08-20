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
    apps.nvim = {
      type = "app";
      program = "${self.packages.${system}.nvim}/bin/nvim";
    };
  };
}
