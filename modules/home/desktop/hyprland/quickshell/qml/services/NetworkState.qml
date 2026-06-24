pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Networking
import QtQuick

// The network devices and their networks as the interface needs them. Views
// read this rather than the network daemon, so a connection attempt is tracked
// in one place and a view only reports what it wants.
Singleton {
    id: root

    // ---- Device discovery ----

    readonly property var wifiDevice: {
        var devs = Networking.devices.values;
        for (var i = 0; i < devs.length; i++)
            if (devs[i].type === DeviceType.Wifi)
                return devs[i];
        return null;
    }

    readonly property var wiredDevice: {
        var devs = Networking.devices.values;
        for (var i = 0; i < devs.length; i++)
            if (devs[i].type === DeviceType.Wired)
                return devs[i];
        return null;
    }

    readonly property bool isEthernet: wiredDevice !== null && wiredDevice.connected
    readonly property bool isWifi: wifiDevice !== null && wifiDevice.connected
    readonly property bool wifiEnabled: Networking.wifiEnabled

    // ---- Primary link ----

    // Both devices can be connected at once, and the one carrying traffic is
    // the one holding the default route. Quickshell reports no primary
    // connection, so the route is read from the kernel.
    //
    // An empty name means the route is not known yet or there is no default
    // route, and a reader falls back to whichever device is connected.
    property string primaryDevice: ""

    readonly property bool isPrimaryWired: wiredDevice !== null && primaryDevice === wiredDevice.name
    readonly property bool isPrimaryWifi: wifiDevice !== null && primaryDevice === wifiDevice.name

    onIsEthernetChanged: root._queryPrimary()
    onIsWifiChanged: root._queryPrimary()

    Component.onCompleted: root._queryPrimary()

    Connections {
        target: Networking

        function onConnectivityChanged() {
            root._queryPrimary();
        }
    }

    function _queryPrimary() {
        // A query already running would report the state before the change, so
        // the request waits for it rather than replacing it.
        if (primaryProc.running) {
            root._primaryPending = true;
            return;
        }

        root._primaryPending = false;
        root._primaryTaken = false;
        primaryProc.running = true;
    }

    property bool _primaryPending: false

    // `ip` prints one line per default route, ordered by metric, and the first
    // one carries the traffic. Later lines are read and discarded so that a
    // second route does not overwrite the answer.
    property bool _primaryTaken: false

    Process {
        id: primaryProc

        command: ["ip", "route", "show", "default"]

        onRunningChanged: {
            if (!primaryProc.running && root._primaryPending)
                root._queryPrimary();
        }

        stdout: SplitParser {
            onRead: line => {
                if (root._primaryTaken)
                    return;

                var match = line.match(/\bdev\s+(\S+)/);
                if (!match)
                    return;

                root.primaryDevice = match[1];
                root._primaryTaken = true;
            }
        }
    }

    // Only Full means the internet is reachable. Portal and Limited both report
    // a link that carries no traffic, which is the state the icon has to show.
    // Unknown is what NetworkManager reports when its connectivity check is
    // disabled, and it counts as no connection here.
    readonly property bool hasConnection: Networking.connectivity === NetworkConnectivity.Full

    readonly property string connectionName: {
        if (isEthernet)
            return wiredDevice.network ? wiredDevice.network.name : "Ethernet";
        if (isWifi)
            return _activeWifiName || "";
        return "";
    }

    readonly property string deviceName: isEthernet ? wiredDevice.name : isWifi ? wifiDevice.name : ""

    property string ipAddress: ""
    property string _activeWifiName: ""
    property int signalPct: 0

    // ---- Networks ----

    readonly property var _allWifiNetworks: (root.wifiDevice && root.wifiDevice.networks) ? root.wifiDevice.networks.values : []

    function _wifiBucket(pred) {
        var out = [];
        for (var i = 0; i < root._allWifiNetworks.length; i++) {
            var n = root._allWifiNetworks[i];
            if (n && pred(n))
                out.push(n);
        }
        return out;
    }

    readonly property var connectedWifiNetworks: _wifiBucket(function (n) {
        return n.connected;
    })

    readonly property var availableWifiNetworks: _wifiBucket(function (n) {
        return !n.connected && (!n.known || root.isTransientNetwork(n));
    })

    readonly property var savedWifiNetworks: _wifiBucket(function (n) {
        return !n.connected && n.known && !root.isTransientNetwork(n);
    })

    function canUsePsk(network) {
        return network && (network.security === WifiSecurityType.WpaPsk || network.security === WifiSecurityType.Wpa2Psk || network.security === WifiSecurityType.Sae);
    }

    // ---- Connection attempts ----

    // A failed attempt leaves the network saved, so an attempt is tracked until
    // it connects or fails. The view shows the result; it does not track it.
    property bool _awaitingConnect: false
    property string _pendingSsid: ""
    property var _pendingNetwork: null
    property bool _pendingWasKnown: false

    // `canRetry` tells the view whether asking for a key again makes sense.
    signal connectionFailed(string ssid, var network, bool canRetry)

    // A network the daemon saved for an attempt that has not succeeded yet.
    // It belongs with the unknown networks until the attempt ends.
    function isTransientNetwork(network) {
        return network && root._awaitingConnect && !root._pendingWasKnown && root._pendingSsid === network.name;
    }

    function connect(network, psk) {
        root._awaitingConnect = true;
        root._pendingSsid = network.name;
        root._pendingNetwork = network;
        root._pendingWasKnown = network.known;

        if (psk !== "")
            network.connectWithPsk(psk);
        else
            network.connect();
    }

    function disconnect(network) {
        network.disconnect();
    }

    function forget(network) {
        network.forget();
    }

    function clearPendingConnection() {
        root._awaitingConnect = false;
        root._pendingSsid = "";
        root._pendingNetwork = null;
        root._pendingWasKnown = false;
    }

    function _markConnectionFailed() {
        if (!root._pendingNetwork || !root._awaitingConnect)
            return;

        var failedNetwork = root._pendingNetwork;
        var failedSsid = root._pendingSsid;
        var failedWasKnown = root._pendingWasKnown;

        root.clearPendingConnection();

        // Drop the entry the daemon saved for the failed attempt.
        if (!failedWasKnown && failedNetwork.known)
            failedNetwork.forget();

        root.connectionFailed(failedSsid, failedNetwork, root.canUsePsk(failedNetwork));
    }

    Connections {
        target: root._pendingNetwork

        function onStateChanged() {
            if (!root._pendingNetwork)
                return;
            if (root._pendingNetwork.state === ConnectionState.Connected)
                root.clearPendingConnection();
            else if (root._pendingNetwork.state === ConnectionState.Disconnected && root._awaitingConnect)
                root._markConnectionFailed();
        }

        function onConnectionFailed(reason) {
            root._markConnectionFailed();
        }
    }

    // ---- Actions ----

    function toggleWifi() {
        Networking.wifiEnabled = !Networking.wifiEnabled;
    }

    // Scan only while a view asks for it.
    function setScanning(wanted) {
        if (root.wifiDevice)
            root.wifiDevice.scannerEnabled = wanted;
    }

    // ---- Live values ----

    // The device reports networks, not which one is active, so track each and
    // keep the name and strength of the connected one.
    Instantiator {
        model: root.wifiDevice ? root.wifiDevice.networks : []

        delegate: Item {
            id: tracker

            required property var modelData

            function syncActive() {
                if (tracker.modelData.connected) {
                    root._activeWifiName = tracker.modelData.name;
                    root.signalPct = Math.round(tracker.modelData.signalStrength * 100);
                }
            }

            Component.onCompleted: syncActive()

            Connections {
                target: tracker.modelData

                function onConnectedChanged() {
                    tracker.syncActive();
                }

                function onSignalStrengthChanged() {
                    if (tracker.modelData.connected)
                        root.signalPct = Math.round(tracker.modelData.signalStrength * 100);
                }
            }
        }
    }

    // One query at a time, and only the query for the current device may
    // report. A running query is left to finish rather than signalled, because
    // a signal returns before the process ends; its output is ignored and the
    // queued query starts when the process is no longer running.
    property string _ipPending: ""
    property bool _ipAccepting: false

    onDeviceNameChanged: {
        root.ipAddress = "";
        root._ipAccepting = false;
        root._ipPending = root.deviceName;
        if (!ipProc.running)
            root._startIpQuery();
    }

    function _startIpQuery() {
        var device = root._ipPending;
        root._ipPending = "";
        if (!device)
            return;

        // Asking by device rather than by connection profile. A wired device
        // reports no network, so the profile name is unknown, while the device
        // name is known for every connected device.
        ipProc.command = ["nmcli", "--terse", "--fields", "IP4.ADDRESS", "device", "show", device];
        root._ipAccepting = true;
        ipProc.running = true;
    }

    Process {
        id: ipProc

        onRunningChanged: {
            if (!ipProc.running)
                root._startIpQuery();
        }

        stdout: SplitParser {
            onRead: line => {
                if (!root._ipAccepting)
                    return;
                var match = line.match(/:(.+)\//);
                if (match)
                    root.ipAddress = match[1];
            }
        }
    }
}
