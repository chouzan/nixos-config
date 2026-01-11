{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.modules) bundles;

  langLdLibs = {
    python = pkgs.python3;
  };

  activeLdLibs = lib.foldlAttrs (
    acc: lang: pkgs:
    acc ++ lib.flatten (lib.optionals (lib.attrByPath [ lang "enable" ] false bundles.dev) pkgs)
  ) [ ] langLdLibs;

  ldRequired = activeLdLibs != [ ];
in
{
  config.programs.nix-ld = lib.mkIf ldRequired {
    enable = true;
    libraries = activeLdLibs;
  };
}
