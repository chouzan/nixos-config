{
  flake.modules.nixos.system-xdg = { lib, ... }: {
    options.modules.system.xdg.enable = lib.mkEnableOption "XDG directory structure management";
  };
}
