{ lib, ... }:

{
  modules = {
    packages = {
      network.enable = lib.mkDefault true;
      archive.enable = lib.mkDefault true;
      cli.enable = lib.mkDefault true;
    };

    programs = {
      git.enable = lib.mkDefault true;
      gh.enable = lib.mkDefault true;
      ripgrep.enable = lib.mkDefault true;
      bat.enable = lib.mkDefault true;
      eza.enable = lib.mkDefault true;
      fzf.enable = lib.mkDefault true;
      zed.enable = lib.mkDefault true;
      claude-code.enable = lib.mkDefault true;
    };

    bundles = {
      container.enable = lib.mkDefault true;
      ai.enable = lib.mkDefault true;

      dev = {
        enable = lib.mkDefault true;
        ruby.enable = lib.mkDefault true;
        python.enable = lib.mkDefault true;
        node.enable = lib.mkDefault true;

        elixir = {
          enable = lib.mkDefault true;
          phoenix.enable = lib.mkDefault true;
        };
      };
    };
  };
}
