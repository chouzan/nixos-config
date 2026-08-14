{ pkgs, ... }:

let
  dev = pkgs.writers.writeNuBin "dev" (builtins.readFile ./scripts/dev.nu);
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
