{
  flake.modules.nixos.programs-ssh = { lib, ... }: {
    options.modules.programs.ssh.enable = lib.mkEnableOption "OpenSSH client configuration";
  };
}
