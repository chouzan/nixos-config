{
  flake.modules.nixos.programs-gh = { lib, ... }: {
    options.modules.programs.gh.enable = lib.mkEnableOption "GitHub CLI tool";
  };
}
