{ libs, ... }:

let
  inherit (libs) utils;
in
{
  modules = {
    system.dns.encrypted.enable = utils.mkProfileDefault true;
    packages.admin.enable = utils.mkProfileDefault true;
    bundles.dev.nix.enable = utils.mkProfileDefault true;

    programs = {
      zsh.enable = utils.mkProfileDefault true;
      vim.enable = utils.mkProfileDefault true;
    };
  };
}
