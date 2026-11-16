{ osConfig, ... }:

let
  inherit (osConfig) modules;
in
{
  home.shell = {
    enableShellIntegration = false;
    enableZshIntegration = modules.programs.zsh.enable;
    enableNushellIntegration = modules.programs.nushell.enable;
  };
}
