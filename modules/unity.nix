{ pkgs, username, ... }:
{
  environment.systemPackages = with pkgs; [ 
    unityhub
    (with dotnetCorePackages; combinePackages [
      sdk_6_0
      sdk_7_0
    ])

    # godot_4-mono # Oh
  ];

  environment.variables.DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "1";
}
