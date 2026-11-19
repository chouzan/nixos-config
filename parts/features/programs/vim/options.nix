{
  flake.modules.nixos.programs-vim = { lib, ... }: {
    options.modules.programs.vim.enable = lib.mkEnableOption "Vim text editor";
  };
}
