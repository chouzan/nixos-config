_:

{
  perSystem =
    { pkgs, ... }:
    let
      inherit (pkgs) lib;

      flakeSrc = ../..;

      nixSource = lib.fileset.toSource {
        root = flakeSrc;

        fileset = lib.fileset.unions [
          (lib.fileset.fileFilter (file: file.hasExt "nix") flakeSrc)
          (flakeSrc + "/statix.toml")
        ];
      };
    in
    {
      checks.nix-static =
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
    };
}
