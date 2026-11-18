{ inputs, self, ... }:

{
  perSystem =
    { pkgs, ... }:
    let
      adminPkgs = pkgs.extend (
        inputs.nixpkgs.lib.composeManyExtensions [
          (import ../overlays/nu-writers.nix)
          (import ../overlays/nixosadm.nix)
        ]
      );
    in
    {
      packages = {
        inherit (adminPkgs) nixosadm;

        installer = self.nixosConfigurations.installer.config.system.build.isoImage;
        wsl = self.nixosConfigurations.wsl.config.system.build.tarballBuilder;
      };
    };
}
