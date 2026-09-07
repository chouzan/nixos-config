{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) modules;
  cfg = modules.system;
in
{
  config = lib.mkIf cfg.nixosadm.enable {
    environment.systemPackages = [ pkgs.nixosadm ];
  };
}
