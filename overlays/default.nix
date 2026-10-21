{ inputs, libs, ... }:

[
  # Upstream overlays
  inputs.hyprland.overlays.hyprland-packages

  # WORKAROUND: XDPH 1.4.1 predates the out-of-buffer fix (#424), and does not
  # coalesce animated resize renegotiation (#216). Remove each patch when its
  # fix reaches the packaged release.
  (_final: prev: {
    xdg-desktop-portal-hyprland = prev.xdg-desktop-portal-hyprland.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        ./patches/xdg-desktop-portal-hyprland/resize-renegotiation.patch
        ./patches/xdg-desktop-portal-hyprland/out-of-buffer-retry.patch
      ];
    });
  })

  inputs.hyprtoolkit.overlays.default
  inputs.hyprpolkitagent.overlays.default

  # hyprgraphics.pc requires glesv2, which hyprpolkitagent does not declare.
  (libs.utils.mkPackageGuardOverlay {
    pname = "hyprpolkitagent";
    overlayLocation = "overlays/default.nix";

    isBroken = pkg: !(builtins.any (dep: (dep.pname or "") == "libglvnd") (pkg.buildInputs or [ ]));

    fallback =
      prev: pkg:
      pkg.overrideAttrs (old: {
        buildInputs = (old.buildInputs or [ ]) ++ [ prev.libglvnd ];
      });
  })

  # The kmod aggregator concatenates a per-module certificate for every
  # out-of-tree module, naming it after the module in `modules.dep`, and the
  # aggregate build fails on the first one missing. Reported as nixpkgs#575192,
  # which lists sixteen more modules in the same position.
  #
  # Kbuild writes that certificate while signing during `modules_install`, so
  # the obvious fix is to install through Kbuild. It does not work here: the
  # kernel sets CONFIG_MODULE_SIG_ALL, but its `dev` output keeps no signing
  # key, so nothing out of tree can be signed and no certificate exists to
  # write. An empty one is what the module actually has, and contributes
  # nothing to the concatenation. The module stays unsigned either way, which
  # loads because CONFIG_MODULE_SIG_FORCE is unset.
  (libs.utils.mkPackageGuardOverlay {
    pname = "linuxPackages_latest";
    label = "zenpower";
    overlayLocation = "overlays/default.nix";

    isBroken =
      kernelPackages:
      inputs.nixpkgs.lib.hasInfix "install -D zenpower.ko" (kernelPackages.zenpower.installPhase or "");

    fallback =
      _prev: kernelPackages:
      kernelPackages.extend (
        _final: prev: {
          # Appended to the phase rather than `postInstall`, which zenpower's
          # own `installPhase` never runs a hook for.
          zenpower = prev.zenpower.overrideAttrs (old: {
            installPhase = old.installPhase + ''
              touch "$out/lib/modules/${prev.kernel.modDirVersion}/kernel/drivers/hwmon/zenpower/zenpower.ko.cer"
            '';
          });
        }
      );
  })

  inputs.hyprpaper.overlays.default
  inputs.hypridle.overlays.default
  inputs.hyprlock.overlays.default
  inputs.hyprland-plugins.overlays.default

  # TODO: Maybe remove zed-editor flake
  # inputs.zed-editor.overlays.default

  inputs.claude-code.overlays.default
  inputs.claude-desktop.overlays.default

  # Custom overlays (no upstream available)
  (import ./nu-writers.nix)
  (import ./nixosadm.nix)
  (import ./mcp-proxy.nix { inherit inputs; })
]
