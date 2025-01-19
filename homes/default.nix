{
  config,
  self,
  impurity,
  inputs,
  username,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    # tell home-manager to be as verbose as possible
    verbose = true;

    # use the system configuration’s pkgs argument
    # this ensures parity between nixos' pkgs and hm's pkgs
    useGlobalPkgs = true;

    # enable the usage user packages through
    # the users.users.<name>.packages option
    useUserPackages = true;

    # move existing files to the .old suffix rather than failing
    # with a very long error message about it
    backupFileExtension = "hm-backup";

    # extra specialArgs passed to Home Manager
    # for reference, the config argument in nixos can be accessed
    # in home-manager through osConfig without us passing it
    extraSpecialArgs = {
      inherit
        self
        inputs
        impurity # to link configs like nvim
        username
        ;
    };

    # username specified in the nixosSystem
    # loads dynamically based on username
    users.${username} = ./${username};
  };

  # Passwords
  # Does not work after creating the users (so far untested).

  sops.secrets.user-password.neededForUsers = true;
  users.mutableUsers = false;
  users.users.${username} = {
    isNormalUser = true;
    initialPassword = "password"; # for first time install, should be overwritten by hashedPasswordFile

    # This caused nothing but pain. Lets just not.
    # must be a hash (mkpasswd). Yes it happened to me. Yes i deleted all passwords and couldnt get in. Counter: 3
    # hashedPasswordFile = config.sops.secrets.user-password.path; 
  };
}
