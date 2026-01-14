{ ... }:

{
  services.udev.extraRules = ''
    # Disable wake-up signal from Logitech USB receivers to prevent unwanted wakeups

    # Logitech (046d) LIGHTSPEED Wireless Receiver (c547)
    ACTION=="bind|add|change", SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c547", ATTR{power/wakeup}="disabled"

    # Logitech (046d) Logi Bolt Receiver (c548)
    ACTION=="bind|add|change", SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c548", ATTR{power/wakeup}="disabled"
  '';
}
