{
  config,
  lib,
  libs,
  ...
}:

let
  inherit (libs) utils;
  hasBtrfs = lib.any (fs: fs.fsType == "btrfs") (lib.attrValues config.fileSystems);
in
{
  services.btrfs.autoScrub.enable = utils.mkModuleDefault hasBtrfs;
}
