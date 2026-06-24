pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Bluetooth
import QtQuick

// The bluetooth adapter and its devices as the interface needs them. Views read
// this rather than the adapter, so the quirks of the daemon stay in one place.
Singleton {
    id: root

    // BluetoothAdapter's return type lacks complete tooling metadata.
    // qmllint disable unresolved-type
    readonly property var adapter: Bluetooth.defaultAdapter
    // qmllint enable unresolved-type

    readonly property bool available: adapter !== null
    readonly property bool powered: available && adapter.enabled
    readonly property bool connected: _connectedCount > 0

    property int _connectedCount: 0

    readonly property var _deviceModel: root.adapter && root.powered ? root.adapter.devices : []

    readonly property var _allDevices: (root.adapter && root.powered && root.adapter.devices) ? root.adapter.devices.values : []

    // Buckets for the menu sections: active on top, new below, saved last.
    function _bucket(pred) {
        var out = [];
        for (var i = 0; i < root._allDevices.length; i++) {
            var d = root._allDevices[i];
            if (d && !d.blocked && pred(d))
                out.push(d);
        }
        return out;
    }

    readonly property var connectedDevices: _bucket(function (d) {
        return d.state === BluetoothDeviceState.Connected;
    })
    readonly property var availableDevices: _bucket(function (d) {
        return !d.paired && d.state !== BluetoothDeviceState.Connected;
    })
    readonly property var savedDevices: _bucket(function (d) {
        return d.paired && d.state !== BluetoothDeviceState.Connected;
    })

    // ---- Icons ----

    // BlueZ classifies a device and reports the result as an icon name, so the
    // kind of device is answered here rather than guessed from its name.
    function iconFor(bluezIcon) {
        var name = "" + (bluezIcon || "");

        if (name.indexOf("headphone") >= 0)
            return "headphones-duotone.svg";
        if (name.indexOf("headset") >= 0)
            return "headset-duotone.svg";
        if (name.indexOf("speaker") >= 0 || name.indexOf("audio") >= 0)
            return "speaker-high-duotone.svg";

        return "bluetooth-duotone.svg";
    }

    // The address as BlueZ writes it, so a caller holding another spelling
    // normalises before asking.
    function iconForAddress(address) {
        var wanted = ("" + (address || "")).toUpperCase();
        if (!wanted)
            return "";

        var devices = root._allDevices;
        for (var i = 0; i < devices.length; i++)
            if (("" + devices[i].address).toUpperCase() === wanted)
                return root.iconFor(devices[i].icon);

        return "";
    }

    // ---- Actions ----

    function togglePower() {
        if (root.adapter)
            root.adapter.enabled = !root.adapter.enabled;
    }

    function pair(device) {
        device.pair();
    }

    function connect(device) {
        device.connect();
    }

    function disconnect(device) {
        device.disconnect();
    }

    function forget(device) {
        device.forget();
    }

    // Scan only while a view asks for it. BlueZ rejects StartDiscovery until
    // the adapter reaches the Enabled state, which it enters through Enabling,
    // so the request is held here and applied again on each state change.
    property bool discoveryWanted: false

    function setDiscovering(wanted) {
        root.discoveryWanted = wanted;
        root._applyDiscovering();
    }

    function _applyDiscovering() {
        if (!root.adapter)
            return;
        root.adapter.discovering = root.discoveryWanted && root.adapter.state === BluetoothAdapterState.Enabled;
    }

    Connections {
        target: root.adapter

        function onStateChanged() {
            root._applyDiscovering();
        }
    }

    // The adapter reports devices, not a count of the connected ones, so track
    // each device and keep the total.
    Instantiator {
        model: root._deviceModel

        delegate: Item {
            id: tracker

            required property var modelData

            Component.onCompleted: {
                if (tracker.modelData.connected)
                    root._connectedCount++;
            }

            Component.onDestruction: {
                if (tracker.modelData.connected)
                    root._connectedCount--;
            }

            Connections {
                target: tracker.modelData

                function onConnectedChanged() {
                    root._connectedCount += tracker.modelData.connected ? 1 : -1;
                }
            }
        }
    }
}
