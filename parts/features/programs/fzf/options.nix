{
  flake.modules.nixos.programs-fzf = { lib, ... }: {
    options.modules.programs.fzf.enable =
      lib.mkEnableOption "fzf (fuzzy finder) with custom configuration";
  };
}
