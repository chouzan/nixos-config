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

  quickshellQml = flakeSrc + "/modules/home/desktop/hyprland/quickshell/qml";

  nixStaticCheck = pkgs.writeNuBinChecked "nix-static-check" { } ./nix-static-check.nu;
  quickshellLayersCheck =
    pkgs.writeNuBinChecked "quickshell-layers-check" { }
      ./quickshell-layers-check.nu;
  quickshellQmlCheck = pkgs.writeNuBinChecked "quickshell-qml-check" { } ./quickshell-qml-check.nu;

  qmlSource = lib.fileset.toSource {
    root = quickshellQml;
    fileset = quickshellQml;
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
        ${lib.getExe nixStaticCheck} ${nixSource}
        touch "$out"
      '';

  # The layering the directories describe, enforced so it cannot quietly rot.
  quickshell-layers = pkgs.runCommandLocal "quickshell-layers-check" { } ''
    ${lib.getExe quickshellLayersCheck} ${qmlSource}
    touch "$out"
  '';

  quickshell-qml =
    pkgs.runCommandLocal "quickshell-qml-check"
      {
        LC_ALL = "C.UTF-8";
        nativeBuildInputs = [ pkgs.qt6.qtdeclarative ];
      }
      ''
        ${lib.getExe quickshellQmlCheck} \
          ${qmlSource} \
          ${pkgs.quickshell}/lib/qt-6/qml \
          ${pkgs.qt6.qtdeclarative}/lib/qt-6/qml
        touch "$out"
      '';
}
