{ config, lib, ... }:
with lib;
let cfg = config.michal.programs.gpu-screen-recorder;
in {
  options.michal.programs.gpu-screen-recorder = {
    enable = mkEnableOption "the gpu-screen-recorder program";
  };

  config = mkIf cfg.enable { programs.gpu-screen-recorder.enable = true; };
}
