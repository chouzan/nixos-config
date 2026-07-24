{ lib, ... }:

{
  options.modules.programs = {
    zsh.enable = lib.mkEnableOption "Zsh shell with custom configuration";
    starship.enable = lib.mkEnableOption "Starship cross-shell prompt";
    vim.enable = lib.mkEnableOption "Vim text editor";
    ssh.enable = lib.mkEnableOption "OpenSSH client configuration";
    gnupg.enable = lib.mkEnableOption "GnuPG agent and pinentry";
    git.enable = lib.mkEnableOption "Git version control with custom configuration";
    jujutsu.enable = lib.mkEnableOption "Jujutsu version control with custom configuration";
    delta.enable = lib.mkEnableOption "delta syntax-highlighting pager for git and jujutsu";
    gh.enable = lib.mkEnableOption "GitHub CLI tool";
    ripgrep.enable = lib.mkEnableOption "ripgrep with custom configuration (includes ripgrep-all)";
    bat.enable = lib.mkEnableOption "bat (cat alternative) with custom configuration";
    eza.enable = lib.mkEnableOption "eza (ls alternative) with custom configuration";
    fzf.enable = lib.mkEnableOption "fzf (fuzzy finder) with custom configuration";
    firefox.enable = lib.mkEnableOption "Firefox web browser with extensions";
    zed.enable = lib.mkEnableOption "Zed code editor (program name: zed-editor)";
    claude-code.enable = lib.mkEnableOption "Claude Code agentic coding tool";
    opencode.enable = lib.mkEnableOption "OpenCode AI coding agent";

    mcp = {
      enable = lib.mkEnableOption "MCP server configuration";

      servers = {
        sequential-thinking.enable = lib.mkEnableOption "sequential-thinking MCP server";
        context7.enable = lib.mkEnableOption "context7 MCP server";
        graphiti-memory.enable = lib.mkEnableOption "graphiti-memory MCP server";
        tidewave.enable = lib.mkEnableOption "tidewave MCP server";
      };
    };

    bitwarden.enable = lib.mkEnableOption "Bitwarden password manager";
    spotify.enable = lib.mkEnableOption "Spotify music player";
  };
}
