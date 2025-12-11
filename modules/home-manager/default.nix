{ ... }:

{
  imports = [
    ./secret.nix
    ./xdg.nix
    ./systemd.nix
    ./shell.nix
    ./container.nix
    ./packages.nix
    ./hyprland.nix
    ./git.nix
    ./dev.nix
    ./editor.nix
    ./ai.nix
    ./stylix.nix
    ./stylix-targets.nix
  ];
}
