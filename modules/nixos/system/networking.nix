{
  config,
  lib,
  machine,
  ...
}:

let
  inherit (machine) hostName user;
in
{
  networking = {
    inherit hostName;
    networkmanager.enable = true;
  };

  users.users.${user.username} = lib.mkIf config.modules.user.enable {
    extraGroups = [
      # Allow the user to change network settings
      "networkmanager"
    ];
  };
}
