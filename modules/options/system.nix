{ lib, ... }:

{
  options.modules.system.xdg.enable = lib.mkEnableOption "XDG directory structure management";
}
