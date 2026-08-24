{ lib }:

let
  getEnabledMonitors = monitors: lib.filter (m: !m.disabled) monitors;

  # Overlay that guards against a broken upstream package. Evaluates
  # `isBroken pkg` at eval time -- if true, calls `fallback pkg` (the
  # caller decides the response). Once upstream is fixed, uses it
  # automatically and prints a trace warning to remove the overlay.
  #
  # Args:
  #   pname           -- nixpkgs attribute name
  #   isBroken        -- pkg -> bool, detection logic
  #   fallback        -- prev -> pkg -> drv, what to use when broken. Takes the
  #                      package set as well, because a fallback that adds a
  #                      missing dependency needs a sibling package.
  #   overlayLocation -- optional string shown in the trace message
  #
  #   mkPackageGuardOverlay {
  #     pname = "kitty";
  #     overlayLocation = "overlays/default.nix";
  #     isBroken = pkg: builtins.readFile "${pkg}/path/to/file" == "";
  #     fallback = prev: pkg: pkg.overrideAttrs (old: { ... });
  #   }
  mkPackageGuardOverlay =
    {
      pname,
      isBroken,
      fallback,
      overlayLocation ? null,
    }:
    (
      _final: prev:
      let
        pkg = prev.${pname};
        hint = lib.optionalString (overlayLocation != null) " in ${overlayLocation}";
      in
      {
        ${pname} =
          if isBroken pkg then
            fallback prev pkg
          else
            builtins.warn "${pname}: upstream is FIXED. Remove its guard overlay${hint}." pkg;
      }
    );

  # Strips SemVer build metadata (everything after `+`) from a version string.
  # Flake packages often have versions like "0.55.3+date=2026-06-07_abc123".
  stripVersionMeta = version: builtins.head (builtins.split "\\+" version);

  orIfNull = fallback: value: if value != null then value else fallback;
  orIfEmpty = fallback: value: if value != [ ] then value else fallback;

  # Returns value unless it's exactly false (allows null and other falsy values)
  orUnless = fallback: value: if builtins.isBool value && !value then fallback else value;

  # Priority hierarchy:
  # - mkOptionDefault (1500)
  # - mkDefault (1000)
  # - * mkModuleDefault (950)
  # - * mkProfileDefault (850)
  # - * mkHostDefault (750)
  # - defaultOverridePriority (100)
  # - mkImageMediaOverride (60)
  # - mkForce (50)
  # - mkVMOverride (10)
  # Reference: https://github.com/NixOS/nixpkgs/blob/master/lib/modules.nix#L1488
  mkModuleDefault = lib.mkOverride 950;
  mkProfileDefault = lib.mkOverride 850;
  mkHostDefault = lib.mkOverride 750;
in
{
  inherit
    getEnabledMonitors
    mkHostDefault
    mkModuleDefault
    mkPackageGuardOverlay
    mkProfileDefault
    orIfEmpty
    orIfNull
    orUnless
    stripVersionMeta
    ;
}
