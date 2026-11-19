{
  flake.modules.nixos.programs-ripgrep = { lib, ... }: {
    options.modules.programs.ripgrep.enable =
      lib.mkEnableOption "ripgrep with custom configuration (includes ripgrep-all)";
  };
}
