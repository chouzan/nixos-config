{ machine, ... }:

let
  inherit (machine) user;
in
{
  imports = [
    ./system
    ./desktop
    ./programs
    ./bundles
    ./packages.nix
    ./stylix
  ];

  programs.home-manager.enable = true;

  home = {
    inherit (user) username;
    homeDirectory = user.homeDir;
  };
}
