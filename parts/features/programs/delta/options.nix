{
  flake.modules.nixos.programs-delta = { lib, ... }: {
    options.modules.programs.delta.enable =
      lib.mkEnableOption "delta syntax-highlighting pager for git and jujutsu";
  };
}
