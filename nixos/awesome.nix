{ config, pkgs, ... }: 
{
  environment.variables = {
    GDK_SCALE = "2.2";
    GDK_DPI_SCALE = "0.4";
    _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2.2";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    # XCURSOR_SIZE = "64";
  };

  services.xserver = {
    enable = true;  
    dpi = 180; # has effect on font (chrome, vscode) but not rofi, that has to be set in lua
    upscaleDefaultCursor = true;
    displayManager = {    
        lightdm.enable = true;    
        defaultSession = "none+awesome";  
    };    
    windowManager.awesome = {
      enable = true;
      package = pkgs.awesome.overrideAttrs (oa: {
        version = "d36e1324d17efd571cec252374a2ef5f1eeae4fd";
        src = pkgs.fetchFromGitHub {
          owner = "awesomeWM";
          repo = "awesome";
          rev = "d36e1324d17efd571cec252374a2ef5f1eeae4fd";
          hash = "sha256-zCxghNGk/GsSt2+9JK8eXRySn9pHXaFhrRU3OtFrDoA=";
        };

        patches = [ ];

        postPatch = ''
          patchShebangs tests/examples/_postprocess.lua
        '';
      });
    };  
  };

}
