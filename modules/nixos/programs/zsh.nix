{
  config,
  lib,
  pkgs,
  machine,
  ...
}:

let
  inherit (machine) user;
  cfg = config.modules.programs.zsh;
in
{
  config = lib.mkIf cfg.enable {
    programs.zsh.enable = true;
    users.users.${user.username}.shell = pkgs.zsh;
  };
}
