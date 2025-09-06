{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Relay
    # Forward local port 8080 to remote host:port
    # `socat TCP-LISTEN:8080,fork TCP:remotehost:80`
    socat
    # Link status: `ethtool wlp192s0`
    ethtool
    traceroute
    whois
  ];

  programs = {
    # sudo arp-scan --localnet
    arp-scan.enable = true;
    # my trace route
    mtr.enable = true;
  };
}
