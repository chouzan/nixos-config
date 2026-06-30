{
  inputs,
  system,
  libs,
  ...
}:

[
  # Upstream overlays
  inputs.hyprland.overlays.hyprland-packages
  inputs.hyprtoolkit.overlays.default
  inputs.hyprpolkitagent.overlays.default

  # hyprpolkitagent upstream missing libglvnd — hyprgraphics.pc requires glesv2.
  # Remove this overlay once upstream adds libglvnd to buildInputs.
  (
    _final: prev:
    let
      hasGlesv2 = builtins.any (dep: (dep.pname or "") == "libglvnd") (
        prev.hyprpolkitagent.buildInputs or [ ]
      );
    in
    {
      hyprpolkitagent =
        if hasGlesv2 then
          builtins.warn "hyprpolkitagent: upstream now includes libglvnd. Remove the libglvnd workaround overlay in overlays/default.nix." prev.hyprpolkitagent
        else
          prev.hyprpolkitagent.overrideAttrs (old: {
            buildInputs = (old.buildInputs or [ ]) ++ [ prev.libglvnd ];
          });
    }
  )

  # xdg-desktop-portal-hyprland from nixpkgs (1.3.12) doesn't build with
  # latest hyprutils — implicit CSharedPointer→bool cast removed. Fixed on
  # main (882ad01e) but no release yet. Pull main + gcc16Stdenv.
  # Remove this overlay once nixpkgs ships xdph > 1.3.12.
  (_final: prev: {
    xdg-desktop-portal-hyprland =
      if builtins.compareVersions prev.xdg-desktop-portal-hyprland.version "1.3.12" > 0 then
        builtins.warn "xdg-desktop-portal-hyprland: >1.3.12 detected. Remove the source override in overlays/default.nix." prev.xdg-desktop-portal-hyprland
      else
        prev.xdg-desktop-portal-hyprland.overrideAttrs (_old: {
          version = "1.3.12-unstable";
          src = prev.fetchFromGitHub {
            owner = "hyprwm";
            repo = "xdg-desktop-portal-hyprland";
            rev = "c01c99fc278ec68c82e9865923088f043c7c1621";
            hash = "sha256-/iSa/bL1QQFLv+uJ9gI0N87J8gOeZXvca7EjoPGKE6w=";
          };
          stdenv = prev.gcc16Stdenv;
        });
  })

  inputs.hyprpaper.overlays.default
  inputs.hypridle.overlays.default
  inputs.hyprlock.overlays.default
  inputs.hyprland-plugins.overlays.default

  # TODO: Maybe remove zed-editor flake
  # inputs.zed-editor.overlays.default

  inputs.claude-code.overlays.default
  inputs.claude-desktop.overlays.default

  # kitty #10102: recursive inotify watch on /nix/store via config symlinks.
  # Workaround: auto_reload_config = -1 in modules/home/desktop/hyprland/default.nix.
  # Remove both this overlay and that setting once kitty ships the fix.
  (_final: prev: {
    kitty =
      if builtins.compareVersions prev.kitty.version "0.48" >= 0 then
        builtins.warn "kitty: inotify watcher bug is likely fixed (>=0.48). Remove auto_reload_config workaround in modules/home/desktop/hyprland/default.nix and this overlay." prev.kitty
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
      if builtins.compareVersions (utils.stripVersionMeta prev.hyprland.version) "0.56" >= 0 then
        builtins.warn "hyprland: >=0.56 detected. Test if page-flip workaround (aquamarine PR#312) is still needed. Run: grep -rn 'TODO.*WORKAROUND.*aquamarine' modules/ overlays/" prev.hyprland
      else
        prev.hyprland;
  })

  # Custom overlays (no upstream available)
  (import ./elixir-expert.nix { inherit inputs system; })
  (import ./mcp-proxy.nix { inherit inputs; })
]
