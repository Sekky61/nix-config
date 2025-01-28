{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    moonlight-qt
  ];
  services.sunshine = {
    enable = true;
    autoStart = false;
    openFirewall = true;
  };
  services.avahi.publish.enable = true;
  services.avahi.publish.userServices = true;
  security.wrappers.sunshine = {
    owner = "root";
    group = "root";
    capabilities = "cap_sys_admin+p";
    source = "${pkgs.sunshine}/bin/sunshine";
  };
}
