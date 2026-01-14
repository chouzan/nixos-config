{ machine, ... }:

let
  inherit (machine) user;
in
{
  users.users.${user.username} = {
    isNormalUser = true;
    description = user.name;

    extraGroups = [
      # Allows the user to change network settings
      "networkmanager"

      "wheel"
    ];
  };
}
