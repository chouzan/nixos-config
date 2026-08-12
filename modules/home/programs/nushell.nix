{ osConfig, lib, ... }:

let
  inherit (osConfig) modules;
  cfg = modules.programs.nushell;
in
{
  config = lib.mkIf cfg.enable {
    programs.nushell = {
      enable = true;

      # NixOS owns the package; Home Manager owns the user configuration.
      package = null;

      settings = {
        show_banner = false;
        edit_mode = "vi";

        cursor_shape = {
          vi_insert = "line";
          vi_normal = "block";
        };

        history = {
          file_format = "sqlite";
          max_size = 50000;
          isolation = false;
          ignore_space_prefixed = true;
        };

        completions.algorithm = "fuzzy";
      };
    };
  };
}
