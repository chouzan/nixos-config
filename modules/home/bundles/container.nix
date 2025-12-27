{
  osConfig,
  lib,
  machine,
  ...
}:

let
  inherit (machine) user;
  cfg = osConfig.modules.bundles;
in
{
  config = lib.mkIf cfg.container.enable {
    services.podman = {
      enable = true;

      settings.storage = {
        storage = {
          # TODO: Explore better settings for btrfs
          driver = "overlay";

          # TODO: Figure out how to fix/coexist with bubblewrap
          # Setting up graphroot cause bubblewrap app to use its own graphroot path
          # which I don't know where, which change the rootless podman SUID/SGID mapping
          # which cause error with layer something which can only be solved with
          # podman system migrate
          graphroot = "${user.dataHome}/containers/storage";

          runroot = "${user.runtimeDir}/containers/storage";
        };
      };
    };
  };
}
