{ machine, ... }:

let
  inherit (machine) user;
in
{
  users.users.${user.username} = {
    isNormalUser = true;
    description = user.name;
    extraGroups = [ "wheel" ];
  };
}
