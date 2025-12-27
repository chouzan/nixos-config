{
  dotenv.enable = true;
  cachix.enable = false;

  env = {
    SOPS_CONFIG = ".secrets/.sops.yaml";
  };

  scripts = {
    sops-edit-nixos.exec = ''
      export SOPS_AGE_KEY_FILE=$HOME/.my/keys/age/nixos.key
      sops edit .secrets/secrets.nixos.yaml
    '';

    sops-edit-home-manager.exec = ''
      export SOPS_AGE_KEY_FILE=$HOME/.my/keys/age/home_manager.key
      sops edit .secrets/secrets.home-manager.yaml
    '';

    sops-info.exec = ''
      echo "Available SOPS scripts:"
      echo "  sops-edit-nixos          - Edit NixOS secrets"
      echo "  sops-edit-home-manager   - Edit Home Manager secrets"
    '';
  };
}
