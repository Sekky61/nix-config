{ pkgs, username, ... }:
{
  environment.systemPackages = with pkgs; [ 
    unityhub
    dotnet-sdk_8
  ];

}
