{
  config,
  lib,
  machine,
  libs,
  ...
}:

let
  inherit (machine) hostName user;
  inherit (libs) utils;
in
{
  networking = {
    inherit hostName;
    networkmanager.enable = utils.mkModuleDefault true;
  };

  users.users.${user.username} = lib.mkIf config.modules.user.enable {
    extraGroups = [
      # Allow the user to change network settings
      "networkmanager"
    ];
  };
}
