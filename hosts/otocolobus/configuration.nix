{ inputs, machine, ... }:

let
  inherit (machine) user;
in
{
  imports = [
    inputs.nixos-wsl.nixosModules.default

    ../shared/system/locale.nix

    ../../modules/nixos

    ../../profiles/base.nix
    ../../profiles/role/development.nix
  ];

  system.stateVersion = "26.05";

  wsl = {
    enable = true;
    defaultUser = user.username;
    wslConf.network.generateHosts = false;
  };

  # WSL manages boot, filesystem, networking, and hardware.
  boot = {
    loader.grub.enable = false;
    plymouth.enable = false;
  };

  networking.networkmanager.enable = false;
  powerManagement.enable = false;

  services = {
    fwupd.enable = false;
    timesyncd.enable = false;
  };

  modules = {
    system.dns.encrypted.enable = false;
    stylix.enable = true;
    programs.zed.enable = false;
    bundles.ai.enable = false;
  };
}
