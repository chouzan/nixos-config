{ lib, ... }:

{
  options.modules.programs = {
    zsh.enable = lib.mkEnableOption "Zsh shell with custom configuration";
    vim.enable = lib.mkEnableOption "Vim text editor";
    git.enable = lib.mkEnableOption "Git version control with custom configuration";
    ripgrep.enable = lib.mkEnableOption "ripgrep with custom configuration (includes ripgrep-all)";
    bat.enable = lib.mkEnableOption "bat (cat alternative) with custom configuration";
    eza.enable = lib.mkEnableOption "eza (ls alternative) with custom configuration";
    fzf.enable = lib.mkEnableOption "fzf (fuzzy finder) with custom configuration";
    firefox.enable = lib.mkEnableOption "Firefox web browser with extensions";
    zed.enable = lib.mkEnableOption "Zed code editor (program name: zed-editor)";
    claude-code.enable = lib.mkEnableOption "Claude Code agentic coding tool";
    bitwarden.enable = lib.mkEnableOption "Bitwarden password manager";
    spotify.enable = lib.mkEnableOption "Spotify music player";
  };
}
