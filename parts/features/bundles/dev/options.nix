{
  flake.modules.nixos.bundles-dev = { lib, ... }: {
    options.modules.bundles.dev = {
      enable = lib.mkEnableOption "uncategorized development tools";
      nix.enable = lib.mkEnableOption "Nix development";
      ruby.enable = lib.mkEnableOption "Ruby development";
      python.enable = lib.mkEnableOption "Python development";
      node.enable = lib.mkEnableOption "Node.js development";

      elixir = {
        enable = lib.mkEnableOption "Elixir development";
        phoenix.enable = lib.mkEnableOption "Phoenix framework development";
      };
    };
  };
}
