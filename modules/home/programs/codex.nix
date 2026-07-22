{ osConfig, lib, ... }:

let
  inherit (osConfig) modules;
  cfg = modules.programs.codex;
in
{
  config = lib.mkIf cfg.enable {
    programs.codex = {
      # Codex owns its user config.toml so it can persist folder-trust
      # decisions there; home-manager leaves it unmanaged and provides the
      # declarative config through the /etc/codex System layer instead (see the
      # nixos codex module).
      enable = true;
    };
  };
}
