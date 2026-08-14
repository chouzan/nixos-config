{ lib, pkgs, ... }:

{
  projectRootFile = "flake.nix";
  programs.nixfmt.enable = true;

  settings = {
    formatter.nufmt = {
      command = lib.getExe pkgs.nufmt;

      options = [
        "--config"
        "${./nufmt.nuon}"
      ];

      includes = [ "*.nu" ];
    };
  };
}
