{
  inputs,
  pkgs,
  username,
  ...
}:
{
  # TODO crashing

  home-manager.users.${username} = _: {
    imports = [
      inputs.anyrun.homeManagerModules.default
    ];
    programs.anyrun = {
      enable = true;
      config = {
        plugins = with inputs.anyrun.packages.${pkgs.system}; [
          applications
          randr
          rink
          shell
          symbols
        ];

        width.fraction = 0.3;
        y.absolute = 15;
        hidePluginInfo = true;
        closeOnClick = true;
      };
    };
  };
}
