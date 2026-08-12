{ osConfig, lib, ... }:

let
  inherit (osConfig) modules;
  cfg = modules.programs.eza;
in
{
  config = lib.mkIf cfg.enable {
    programs.eza = {
      enable = true;

      # Eza emits text, so its aliases replace Nushell's structured `ls` output.
      # TODO: Revisit when eza-community/eza#472 lands and Home Manager preserves
      # Nushell records.
      enableNushellIntegration = false;

      git = true;
      icons = "auto";
    };
  };
}
