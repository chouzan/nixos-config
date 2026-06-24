pragma Singleton

import Quickshell
import Quickshell.Services.UPower

// The battery as the interface needs it. Views read this rather than UPower, so
// the state of the daemon is read in one place and given as plain values.
Singleton {
    id: root

    readonly property var device: UPower.displayDevice
    readonly property bool hasBattery: device && device.isPresent

    // The display device carries the charge, but not the health of the cell,
    // which only the laptop battery itself reports.
    readonly property var _laptopBattery: {
        var devices = UPower.devices.values;
        for (var i = 0; i < devices.length; i++)
            if (devices[i].isLaptopBattery && devices[i].isPresent)
                return devices[i];
        return null;
    }

    readonly property real percentage: hasBattery ? device.percentage * 100 : 0
    readonly property bool charging: hasBattery && device.state === UPowerDeviceState.Charging
    readonly property bool fullyCharged: hasBattery && device.state === UPowerDeviceState.FullyCharged
    readonly property real changeRate: hasBattery ? Math.abs(device.changeRate) : 0
    readonly property int timeToFull: hasBattery ? device.timeToFull : 0
    readonly property int timeToEmpty: hasBattery ? device.timeToEmpty : 0
    readonly property bool healthSupported: _laptopBattery !== null && _laptopBattery.healthSupported
    readonly property real health: _laptopBattery ? _laptopBattery.healthPercentage : 0
}
