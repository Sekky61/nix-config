{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    libsForQt5.plasma-browser-integration
    google-chrome
    (pkgs.writeShellScriptBin "google-chrome" "exec -a $0 ${google-chrome}/bin/google-chrome-stable $@")
  ];

  environment.sessionVariables = {
    BROWSER = "google-chrome";
  };
}
