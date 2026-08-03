{ lib, pkgs, ... }:

{
  options.modules.programs = {
    zsh.enable = lib.mkEnableOption "Zsh shell with custom configuration";
    nushell.enable = lib.mkEnableOption "Nushell with custom configuration";
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
    zoxide.enable = lib.mkEnableOption "zoxide smarter cd command";
    carapace.enable = lib.mkEnableOption "Carapace multi-shell command argument completer";
    firefox.enable = lib.mkEnableOption "Firefox web browser with extensions";
    zed.enable = lib.mkEnableOption "Zed code editor (program name: zed-editor)";

    claude-code = {
      enable = lib.mkEnableOption "Claude Code agentic coding tool";

      systemSettings = lib.mkOption {
        inherit (pkgs.formats.json { }) type;
        default = { };
        internal = true;
        description = "Composable policy for the Claude Code managed settings layer";
      };

      userSettings = lib.mkOption {
        inherit (pkgs.formats.json { }) type;
        default = { };
        internal = true;
        description = "Composable preferences merged into the writable Claude Code user settings";
      };
    };

    codex = {
      enable = lib.mkEnableOption "Codex CLI agentic coding tool";

      systemSettings = lib.mkOption {
        inherit (pkgs.formats.toml { }) type;
        default = { };
        internal = true;
        description = "Composable settings for the Codex System configuration layer";
      };
    };

    opencode.enable = lib.mkEnableOption "OpenCode agentic coding tool";
    llm-plugins.caveman.enable = lib.mkEnableOption "Caveman workflow plugin for LLM coding agents";

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
