{ libs, ... }:

let
  inherit (libs) utils;
in
{
  services.btrfs.autoScrub.enable = utils.mkModuleDefault true;
}
