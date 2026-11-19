{
  flake.modules.nixos.programs-gnupg = { lib, ... }: {
    options.modules.programs.gnupg.enable = lib.mkEnableOption "GnuPG agent and pinentry";
  };
}
