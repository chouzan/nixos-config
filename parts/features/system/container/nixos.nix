{
  flake.modules.nixos.system-container =
    {
      config,
      lib,
      pkgs,
      machine,
      ...
    }:

    let
      inherit (machine) user;
      cfg = config.modules.system.container;
    in
    {
      config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [ podman-compose ];

        virtualisation = {
          podman = {
            enable = true;
            defaultNetwork.settings.dns_enabled = true;
          };

          quadlet.enable = true;

          containers.storage.rootful.settings = {
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
    };
}
