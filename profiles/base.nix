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
      nushell.enable = utils.mkProfileDefault true;
      zoxide.enable = utils.mkProfileDefault true;
      carapace.enable = utils.mkProfileDefault true;
      vim.enable = utils.mkProfileDefault true;
    };
  };
}
