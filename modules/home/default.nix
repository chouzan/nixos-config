{ osConfig, machine, ... }:

let
  inherit (osConfig) modules;
  inherit (machine) user;
in
{
  programs.home-manager.enable = true;

  home = {
    inherit (user) username;
    inherit (modules.user) homeDirectory;
    preferXdgDirectories = modules.system.xdg.enable;
  };
}
