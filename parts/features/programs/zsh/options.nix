{
  flake.modules.nixos.programs-zsh = { lib, ... }: {
    options.modules.programs.zsh.enable = lib.mkEnableOption "Zsh shell with custom configuration";
  };
}
