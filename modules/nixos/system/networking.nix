{ machine, ... }:

let
  inherit (machine) hostName user;
in
{
  networking = {
    inherit hostName;
    networkmanager.enable = true;
  };

  users.users.${user.username} = {
    extraGroups = [
      # Allow the user to change network settings
      "networkmanager"
    ];
  };
}
