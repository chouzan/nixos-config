{ libs, ... }:

let
  inherit (libs) utils;
in
{
  modules = {
    packages.admin.enable = utils.mkProfileDefault true;
    bundles.dev.nix.enable = utils.mkProfileDefault true;

    programs = {
      zsh.enable = utils.mkProfileDefault true;
      vim.enable = utils.mkProfileDefault true;
    };
  };
}
