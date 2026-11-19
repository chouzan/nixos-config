{
  flake.modules.nixos.programs-bitwarden = { lib, ... }: {
    options.modules.programs.bitwarden.enable = lib.mkEnableOption "Bitwarden password manager";
  };
}
