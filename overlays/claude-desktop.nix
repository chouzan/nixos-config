{ inputs, ... }:

_final: prev:
let
  src = inputs.claude-desktop;

  # Revision known to require the nodePackages.asar patch
  knownBrokenRev = "b2b040cb68231d2118906507d9cc8fd181ca6308";
  currentRev = src.rev or "";
  isUnchanged = currentRev == knownBrokenRev;

  upstreamWorks =
    (builtins.tryEval (
      builtins.seq inputs.claude-desktop.packages.${prev.system}.claude-desktop.drvPath true
    )).success;

  patchy-cnb = prev.callPackage "${src}/pkgs/patchy-cnb.nix" { };

  patchedPkg = prev.callPackage "${src}/pkgs/claude-desktop.nix" {
    inherit patchy-cnb;

    # nodePackages was removed from nixpkgs; provide asar directly
    nodePackages = { inherit (prev) asar; };
  };
in
{
  claude-desktop =
    if isUnchanged then
      patchedPkg
    else if upstreamWorks then
      builtins.trace
        "warning: claude-desktop upstream fixed; remove the overlay patch in overlays/claude-desktop.nix"
        inputs.claude-desktop.packages.${prev.system}.claude-desktop
    else
      builtins.trace "notice: claude-desktop (${currentRev}) still requires nodePackages.asar patch" patchedPkg;
}
