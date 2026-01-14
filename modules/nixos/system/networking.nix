{ machine, ... }:

{
  networking = {
    hostName = machine.hostname;
    networkmanager.enable = true;
  };
}
