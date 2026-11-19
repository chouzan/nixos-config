{
  flake.modules.nixos.programs-jujutsu = { lib, ... }: {
    options.modules.programs.jujutsu.enable =
      lib.mkEnableOption "Jujutsu version control with custom configuration";
  };
}
