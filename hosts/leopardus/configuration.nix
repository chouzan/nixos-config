# Leopardus - NixOS Installer ISO
#
# Build: nix build .#installer
# Write: sudo dd if=result/iso/*.iso of=/dev/sdX bs=4M status=progress
# Boot and run: sudo menu

{
  inputs,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"

    ../../modules/nixos

    ../shared/system/locale.nix
  ];

  isoImage = {
    makeEfiBootable = true;
    makeUsbBootable = true;
  };

  # Latest kernel may outpace ZFS support
  boot.supportedFilesystems.zfs = false;

  # Embed flake in ISO for nixos-install
  environment.etc."nixos-config".source = ../..;

  services = {
    # No network at boot for auto-detection
    automatic-timezoned.enable = false;

    openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };

    getty.autologinUser = lib.mkForce "root";
  };

  # Fallback since automatic-timezoned is disabled
  time.timeZone = "UTC";

  console = {
    font = "ter-v22n";
    packages = [ pkgs.terminus_font ];
  };

  modules = {
    user.enable = false;
    packages.admin.enable = true;
    programs.vim.enable = true;
  };

  environment.systemPackages = [
    inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.default

    (pkgs.writeScriptBin "menu" (builtins.readFile ../../scripts/installer/menu.sh))
    (pkgs.writeScriptBin "help" (builtins.readFile ../../scripts/installer/help.sh))

    (pkgs.writeScriptBin "manual-partition" (
      builtins.readFile ../../scripts/installer/manual-partition.sh
    ))

    (pkgs.writeScriptBin "welcome" (builtins.readFile ../../scripts/installer/welcome.sh))
  ];

  programs.bash.interactiveShellInit = ''
    if [ "$(tty)" = "/dev/tty1" ]; then
      welcome
    fi
  '';
}
