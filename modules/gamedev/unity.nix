{
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    unityhub
    (
      with dotnetCorePackages;
        combinePackages [
          sdk_6_0
          sdk_7_0
        ]
    )
  ];

  environment.variables.DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "1";
}
