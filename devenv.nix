{ pkgs, ... }:

let
  # devenv brings its own package set, so the writer that reports a Nushell
  # parse error at build time has to be added to it here.
  nuPkgs = pkgs.extend (import ./overlays/nu-writers.nix);

  dev = nuPkgs.writeNuBinChecked "dev" { } ./scripts/dev.nu;
in
{
  packages = [
    dev
  ]
  ++ (with pkgs; [
    age
    sops
    wl-clipboard
  ]);

  env = {
    SOPS_CONFIG = ".secrets/.sops.yaml";
  };

  enterShell = ''
    dev
  '';
}
