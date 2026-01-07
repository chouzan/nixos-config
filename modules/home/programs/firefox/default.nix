{ osConfig, lib, ... }:

let
  cfg = osConfig.modules.programs.firefox;
in
{
  imports = [
    ./containers.nix
    ./extensions
  ];

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;

      profiles.default = {
        id = 0;
        name = "default";
        path = "92oz7e9w.default";
        isDefault = true;
      };
    };
  };
}
