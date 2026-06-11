{
  inputs,
  system,
  libs,
  ...
}:

let
  inherit (libs.utils) mkPackageGuardOverlay;
in
[
  # Upstream overlays
  inputs.hyprland.overlays.hyprland-packages
  inputs.hyprtoolkit.overlays.default
  inputs.hyprpolkitagent.overlays.default
  inputs.hyprpaper.overlays.default
  inputs.hypridle.overlays.default
  inputs.hyprlock.overlays.default
  inputs.hyprland-plugins.overlays.default

  # TODO: Maybe remove zed-editor flake
  # inputs.zed-editor.overlays.default

  inputs.claude-code.overlays.default

  (mkPackageGuardOverlay {
    pname = "kitty";
    overlayLocation = "overlays/default.nix";
    isBroken = pkg: builtins.readFile "${pkg}/lib/kitty/kitty/options/types.py" == "";
    fallback =
      pkg:
      pkg.overrideAttrs (old: {
        env = (old.env or { }) // {
          NIX_REBUILD_KITTY = "cache-corruption-workaround";
        };
      });
  })

  # kitty #10102: recursive inotify watch on /nix/store via config symlinks.
  # Workaround: auto_reload_config = -1 in modules/home/desktop/hyprland/default.nix.
  # Remove both this overlay and that setting once kitty ships the fix.
  (_final: prev: {
    kitty =
      if builtins.compareVersions prev.kitty.version "0.48" >= 0 then
        builtins.trace "kitty: inotify watcher bug is likely fixed (>=0.48). Remove auto_reload_config workaround in modules/home/desktop/hyprland/default.nix and this overlay." prev.kitty
      else
        prev.kitty;
  })

  # aquamarine#240: initial DRM commit drops page-flip with no retry.
  # Fix: aquamarine PR#312. Workaround: re-modeset in settings/default.nix
  # and hypridle.nix. grep "TODO.*WORKAROUND.*aquamarine" to find all sites.
  # Remove this overlay and all workaround markers once the fix ships.
  (_final: prev: {
    hyprland =
      let
        inherit (libs) utils;
      in
      if builtins.compareVersions (utils.stripVersionMeta prev.hyprland.version) "0.55.3" > 0 then
        builtins.trace "hyprland: >0.55.3 detected. Test if page-flip workaround (aquamarine PR#312) is still needed. Run: grep -rn 'TODO.*WORKAROUND.*aquamarine' modules/ overlays/" prev.hyprland
      else
        prev.hyprland;
  })

  # Custom overlays (no upstream available)
  (import ./claude-desktop.nix { inherit inputs system; })
  (import ./elixir-expert.nix { inherit inputs system; })
  (import ./mcp-proxy.nix { inherit inputs; })
]
