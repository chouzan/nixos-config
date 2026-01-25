{
  config,
  lib,
  machine,
  ...
}:

let
  inherit (machine) user;
  cfg = config.modules.user;
in
{
  config = lib.mkIf cfg.enable {
    users.users.${user.username} = {
      inherit (cfg) uid;
      isNormalUser = true;
      description = user.name;
      extraGroups = [ "wheel" ];
    };
  };
}
