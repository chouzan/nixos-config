{ ... }:

{
  programs.nh = {
    enable = true;
    flake = "/etc/nixos";
    clean.enable = true;
    clean.extraArgs = "--keep-since 30d --keep 7";
  };
}
