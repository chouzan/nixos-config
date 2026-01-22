{ machine, ... }:

let
  inherit (machine) hostname user;
in
{
  networking = {
    hostName = hostname;
    networkmanager.enable = true;
  };

  users.users.${user.username} = {
    extraGroups = [
      # Allow the user to change network settings
      "networkmanager"
    ];
  };
}
