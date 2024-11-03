{
  pkgs,
  username,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    dive # for exploring docker images layers
  ];

  # virtualisation
  virtualisation = {
    docker.enable = true;
  };

  # user needs to be in the docker group
  users = {
    users.${username} = {
      extraGroups = [
        "docker"
      ];
    };
  };
}
