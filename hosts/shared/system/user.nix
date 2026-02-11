{ config, machine, ... }:

let
  inherit (machine) user;
  cfg = config.modules.user;
in
{
  users.users.${user.username} = {
    inherit (cfg) uid;
    isNormalUser = true;
    description = user.name;
    extraGroups = [ "wheel" ];
  };
}
