{ nixosConfig, ... }:

{
  stylix = {
    autoEnable = true;

    targets = {
      firefox.enable = false;
      kde.enable = false;
      qt.enable = nixosConfig.stylix.targets.qt.enable;
    };
  };
}
