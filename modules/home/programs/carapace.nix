{ osConfig, lib, ... }:

let
  inherit (osConfig) modules;
  cfg = modules.programs.carapace;
in
{
  config = lib.mkIf cfg.enable {
    programs.carapace = {
      enable = true;

      # Preserve Zsh's native completion stack.
      enableZshIntegration = false;
    };
  };
}
