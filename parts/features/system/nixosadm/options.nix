{
  flake.modules.nixos.system-nixosadm = { lib, ... }: {
    options.modules.system.nixosadm.enable =
      lib.mkEnableOption "nixosadm system administration command";
  };
}
