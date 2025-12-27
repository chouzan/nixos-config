{
  config,
  lib,
  pkgs,
  machine,
  ...
}:

let
  inherit (machine) user;
  cfg = config.modules.programs.spotify;
in
{
  config = lib.mkIf cfg.enable {
    users.users.${user.username}.packages = with pkgs; [ spotify ];

    networking.firewall = {
      # Sync local tracks from filesystem with mobile devices in the same network
      allowedTCPPorts = [ 57621 ];

      # Enable discovery of Google Cast devices in the same network
      allowedUDPPorts = [ 5353 ];
    };
  };
}
