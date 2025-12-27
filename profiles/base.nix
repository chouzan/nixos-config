{ lib, ... }:

{
  modules = {
    packages.admin.enable = lib.mkDefault true;
    bundles.dev.nix.enable = lib.mkDefault true;

    programs = {
      zsh.enable = lib.mkDefault true;
      vim.enable = lib.mkDefault true;
    };
  };
}
