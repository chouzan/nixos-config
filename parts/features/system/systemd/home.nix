{
  flake.modules.homeManager.system-systemd =
    { ... }:

    {
      # Auto-manage user service changes during rebuild
      systemd.user.startServices = "sd-switch";
    };
}
