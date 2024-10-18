{
  inputs,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    libsForQt5.plasma-browser-integration
    google-chrome
  ];

  environment.sessionVariables = {
    BROWSER = "google-chrome";
  };
}
