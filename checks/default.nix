{ pkgs, flakeSrc, ... }:

let
  inherit (pkgs) lib;

  nixSource = lib.fileset.toSource {
    root = flakeSrc;

    fileset = lib.fileset.unions [
      (lib.fileset.fileFilter (file: file.hasExt "nix") flakeSrc)
      (flakeSrc + "/statix.toml")
    ];
  };
in
{
  nix-static =
    pkgs.runCommandLocal "nix-static-check"
      {
        nativeBuildInputs = with pkgs; [
          nixf
          statix
          deadnix
        ];
      }
      ''
        ${lib.getExe pkgs.nushell} ${./nix-static-check.nu} ${nixSource}
        touch "$out"
      '';
}
