{
  flake.modules.nixos.programs-firefox = { lib, ... }: {
    options.modules.programs.firefox.enable = lib.mkEnableOption "Firefox web browser with extensions";
  };
}
