{ lib }:

let
  getEnabledMonitors = monitors: lib.filter (m: !m.disabled) monitors;

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
    mkProfileDefault
    orIfEmpty
    orIfNull
    orUnless
    ;
}
