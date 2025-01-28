{
  inputs,
  pkgs,
  username,
  ...
}: {
  home-manager.users.${username} = _: {
    imports = [
      inputs.anyrun.homeManagerModules.default
    ];
    programs.anyrun = {
      enable = true;
      config = {
        plugins = with inputs.anyrun.packages.${pkgs.system}; [
          applications
          randr # todo not working?
          rink # calculator
          shell
          symbols # search unicode
        ];

        width.fraction = 0.3;
        y.absolute = 15;

        hidePluginInfo = true;
        closeOnClick = true;
      };
    };
  };
}
