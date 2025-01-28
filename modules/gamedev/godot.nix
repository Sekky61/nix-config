{
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    godot_4
  ];
}
