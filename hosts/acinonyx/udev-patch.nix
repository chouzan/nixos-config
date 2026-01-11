{ ... }:

{
  services.udev.extraRules = ''
    # Disable the wake-up signal from the offending PCIe device that prevents the machine from suspending
    # This is the AMD USB host controller (gateway device)
    # ACTION=="bind|add|change", SUBSYSTEM=="pci", ATTR{vendor}=="0x1022", ATTR{device}=="0x1639", ATTR{power/control}="auto", ATTR{power/autosuspend_delay_ms}="1800000", ATTR{power/wakeup}="disabled"

    # TODO: Figure out how to make it so the device can still wake up from user inputs
    # Not setting the autosuspend_delay_ms may actually works but it makes the
    # deivce unresponsive every 2 seconds (default autosuspend time) unattended
    #
    # Disable the wake-up signal from the offending USB device that prevents the machine from suspending
    # This is the Logitech USB receiver
    ACTION=="bind|add|change", SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c547", ATTR{power/control}="auto", ATTR{power/autosuspend_delay_ms}="1800000", ATTR{power/wakeup}="disabled"
  '';
}
