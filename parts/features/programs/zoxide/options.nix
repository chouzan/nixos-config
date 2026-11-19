{
  flake.modules.nixos.programs-zoxide = { lib, ... }: {
    options.modules.programs.zoxide.enable = lib.mkEnableOption "zoxide smarter cd command";
  };
}
