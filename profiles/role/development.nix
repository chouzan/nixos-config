{ libs, ... }:

let
  inherit (libs) utils;
in
{
  modules = {
    packages = {
      network.enable = utils.mkProfileDefault true;
      archive.enable = utils.mkProfileDefault true;
      cli.enable = utils.mkProfileDefault true;
    };

    programs = {
      starship.enable = utils.mkProfileDefault true;
      ssh.enable = utils.mkProfileDefault true;
      gnupg.enable = utils.mkProfileDefault true;
      git.enable = utils.mkProfileDefault true;
      jujutsu.enable = utils.mkProfileDefault true;
      delta.enable = utils.mkProfileDefault true;
      gh.enable = utils.mkProfileDefault true;
      ripgrep.enable = utils.mkProfileDefault true;
      bat.enable = utils.mkProfileDefault true;
      eza.enable = utils.mkProfileDefault true;
      fzf.enable = utils.mkProfileDefault true;
      zed.enable = utils.mkProfileDefault true;
      llm = {
        claude-code.enable = utils.mkProfileDefault true;
        codex.enable = utils.mkProfileDefault true;
        opencode.enable = utils.mkProfileDefault true;
        plugins.caveman.enable = utils.mkProfileDefault true;
      };

      mcp = {
        enable = utils.mkProfileDefault true;

        servers = {
          sequential-thinking.enable = utils.mkProfileDefault true;
          context7.enable = utils.mkProfileDefault true;
          tidewave.enable = utils.mkProfileDefault true;
        };
      };
    };

    bundles = {
      container.enable = utils.mkProfileDefault true;
      ai.enable = utils.mkProfileDefault true;

      dev = {
        enable = utils.mkProfileDefault true;
        ruby.enable = utils.mkProfileDefault true;
        python.enable = utils.mkProfileDefault true;
        node.enable = utils.mkProfileDefault true;

        elixir = {
          enable = utils.mkProfileDefault true;
          phoenix.enable = utils.mkProfileDefault true;
        };
      };
    };
  };
}
