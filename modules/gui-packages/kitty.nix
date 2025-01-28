{
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    kitty
    # other system-wide packages...
  ];
}
