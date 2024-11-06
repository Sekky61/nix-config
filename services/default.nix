{ config, lib, hostname, runningServices, ... }:
with lib;
let
  anyServices = runningServices != null;

  servicesToRun = map (name: ./${name}.nix) (attrNames runningServices);

in {
  imports = []
    ++ (if anyServices then [ ./service_proxy.nix ] else [])
    ++ servicesToRun;
}
