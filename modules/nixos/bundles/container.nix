{
  config,
  lib,
  pkgs,
  machine,
  ...
}:

let
  inherit (machine) user;
  cfg = config.modules.bundles;
in
{
  config = lib.mkIf cfg.container.enable {
    environment.systemPackages = with pkgs; [ podman-compose ];

    virtualisation = {
      podman = {
        enable = true;
        defaultNetwork.settings.dns_enabled = true;
      };

      quadlet.enable = true;

      containers.storage.settings = {
        # TODO: Explore better settings for btrfs
        storage = {
          driver = "overlay";
          graphroot = "/var/lib/containers/storage";
          runroot = "/run/containers/storage";
        };
      };
    };

    users.users.${user.username} = {
      autoSubUidGidRange = true;
      linger = true;
    };
  };
}
