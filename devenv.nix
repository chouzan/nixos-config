{ pkgs, ... }:

let
  mkSopsEdit = name: ''
    export SOPS_AGE_KEY_FILE=$HOME/.my/keys/age/${name}.key
    sops edit .secrets/secrets.${name}.yaml
  '';

  mkSopsCopy = name: ''
    export SOPS_AGE_KEY_FILE=$HOME/.my/keys/age/${name}.key
    if value=$(sops --decrypt --extract "[\"$1\"]" .secrets/secrets.${name}.yaml 2>&1); then
      printf '%s' "$value" | wl-copy
      echo "copied '$1' to clipboard."
    else
      echo "error: sops: key '$1' not found in ${name} secrets." >&2
      exit 1
    fi
  '';
in
{
  dotenv.enable = true;
  cachix.enable = false;

  packages = with pkgs; [
    age
    deadnix
    sops
    statix
    wl-clipboard
  ];

  env = {
    SOPS_CONFIG = ".secrets/.sops.yaml";
  };

  scripts = {
    nix-static-check.exec = ''
      statix check .
      deadnix .
    '';

    sops-edit-nixos.exec = mkSopsEdit "nixos";
    sops-edit-home.exec = mkSopsEdit "home";

    sops-copy-nixos.exec = mkSopsCopy "nixos";
    sops-copy-home.exec = mkSopsCopy "home";

    sops-info.exec = ''
      echo "Available SOPS scripts:"
      echo "  sops-edit-nixos              - Edit NixOS secrets"
      echo "  sops-edit-home               - Edit Home Manager secrets"
      echo "  sops-copy-nixos <key>        - Copy NixOS secret to clipboard"
      echo "  sops-copy-home <key>         - Copy Home Manager secret to clipboard"
    '';
  };
}
