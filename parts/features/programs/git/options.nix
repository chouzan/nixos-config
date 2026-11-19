{
  flake.modules.nixos.programs-git = { lib, ... }: {
    options.modules.programs.git.enable =
      lib.mkEnableOption "Git version control with custom configuration";
  };
}
