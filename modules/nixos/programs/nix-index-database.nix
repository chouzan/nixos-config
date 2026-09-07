{
  config,
  inputs,
  lib,
  libs,
  pkgs,
  ...
}:

let
  inherit (libs) utils;

  cfg = config.modules.programs.nix-index-database;
  system = pkgs.stdenv.hostPlatform.system;
  nixIndexSmallDb = inputs.nix-index-database.packages.${system}.nix-index-with-small-db;
in
{
  # The upstream nix-index-database module turns itself on as soon as it is
  # imported, so the option is assigned rather than guarded.
  config.programs.nix-index-database = {
    inherit (cfg) enable;
    comma.enable = cfg.enable;
  };

  # The small database indexes only files under /bin, which is what comma and a
  # command lookup need. The full database is pinned by the lock file, so every
  # update of that input fetches the whole index again.
  config.programs.nix-index = lib.mkIf cfg.enable {
    package = utils.mkModuleDefault nixIndexSmallDb;
  };
}
