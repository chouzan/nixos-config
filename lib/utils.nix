{ lib }:

let
  getEnabledMonitors = monitors: lib.filter (m: !m.disabled) monitors;

  # Returns value unless it's exactly false (allows null and other falsy values)
  orUnless = fallback: value: if value != false then value else fallback;
  orIfNull = fallback: value: if value != null then value else fallback;
  orIfEmpty = fallback: value: if value != [ ] then value else fallback;

  # Priority hierarchy:
  # - mkOptionDefault(1500)
  # - * mkModuleDefault(1450)
  # - * mkProfileDefault(1350)
  # - mkDefault(1000)
  # - mkForce(50)
  mkModuleDefault = lib.mkOverride 1450;
  mkProfileDefault = lib.mkOverride 1350;
in
{
  inherit
    getEnabledMonitors
    mkModuleDefault
    mkProfileDefault
    orUnless
    orIfNull
    orIfEmpty
    ;
}
