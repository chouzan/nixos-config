{ osConfig, ... }:

let
  inherit (osConfig) modules;
in
{
  imports = [
    ./zsh.nix
    ./nushell.nix
    ./starship
    ./ssh.nix
    ./gnupg.nix
    ./git
    ./jujutsu
    ./delta.nix
    ./gh.nix
    ./ripgrep.nix
    ./bat.nix
    ./eza.nix
    ./fzf.nix
    ./zoxide.nix
    ./carapace.nix
    ./firefox
    ./zed
    ./claude-code
    ./codex.nix
    ./opencode.nix
    ./llm-plugins
    ./mcp.nix
    ./bitwarden.nix
  ];

  home.shell = {
    enableShellIntegration = false;
    enableZshIntegration = modules.programs.zsh.enable;
    enableNushellIntegration = modules.programs.nushell.enable;
  };
}
