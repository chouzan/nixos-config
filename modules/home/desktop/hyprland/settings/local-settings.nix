{ osConfig, lib, ... }:

let
  cfg = osConfig.modules.desktop.hyprland;
  toLua = lib.generators.toLua { };

  # Load the dir's `init.lua` (if present) after the generated config, so local
  # overrides win over module defaults.
  loadLocalDir =
    dir:
    let
      relativePath = toLua "/${dir}/init.lua";
    in
    ''
      do
        local path = assert(os.getenv("HOME"), "HOME is not set") .. ${relativePath}
        local handle = io.open(path, "r")

        if handle then
          handle:close()
          assert(loadfile(path))()
        end
      end
    '';
in
{
  config = lib.mkIf (cfg.enable && cfg.localSettings.enable) {
    wayland.windowManager.hyprland.extraConfig =
      lib.concatMapStringsSep "\n" loadLocalDir
        cfg.localSettings.dirs;
  };
}
