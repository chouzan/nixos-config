pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick

// Single source of truth for notifications. Owns the one NotificationServer
// (only one process may own the D-Bus name), and splits its stream into two
// views: transient `toasts` (rendered by NotificationToast, capped and
// auto-expiring) and a persistent `history` (rendered by the notification
// centre). History, the pinned flag, and Do-Not-Disturb survive a bar restart
// via a JSON state file under ~/.local/state/quickshell.
Singleton {
    id: root

    readonly property int maxToasts: 5
    readonly property int maxHistory: 100
    readonly property int dismissTimeout: 5000

    // Live notification objects by id, so a toast can still invoke actions.
    property var notifMap: ({})

    // Ids for locally-emitted notifications (prayer times, etc.) — negative so
    // they never collide with the server's positive notification ids.
    property int _localSeq: 0

    // Transient popup queue (not persisted).
    readonly property alias toasts: toastModel
    ListModel { id: toastModel }

    // Open notification centres, counted because each monitor has its own.
    // A toast would only repeat what an open centre already lists, so while one
    // is open new notifications go straight to history and the live toasts fade
    // out (see NotificationToast).
    property int _openCentres: 0
    readonly property bool centreOpen: root._openCentres > 0

    function acquireCentre() {
        root._openCentres += 1;
    }

    function releaseCentre() {
        root._openCentres = Math.max(0, root._openCentres - 1);
    }

    // Persisted history + settings.
    readonly property alias history: store.history
    readonly property alias dnd: store.dnd
    readonly property alias _store: store
    property int unreadCount: 0

    // Priority-based history lifetime: an entry auto-clears once its age passes
    // the per-urgency TTL (unless pinned); Critical never auto-clears. Low and
    // Normal are the knobs.
    readonly property int ttlLow: 24 * 60 * 60 * 1000         // 1 day
    readonly property int ttlNormal: 3 * 24 * 60 * 60 * 1000  // 3 days

    // History with expired entries filtered out, re-evaluated hourly so entries
    // drop even while the centre is open. The centre renders THIS, not `history`.
    readonly property var visibleHistory: {
        var now = pruneClock.date.getTime()
        return root.history.filter((e) => !root._expired(e, now))
    }

    // `visibleHistory` is rebuilt whenever the log changes, so a view bound
    // straight to it would recreate every row. This model mirrors it through
    // insert, remove and set instead, which keeps untouched rows alive and lets
    // the view animate the ones that actually arrive or leave.
    readonly property alias visibleHistoryModel: historyModel
    ListModel { id: historyModel }

    onVisibleHistoryChanged: root._syncHistoryModel()

    function _syncHistoryModel() {
        var entries = root.visibleHistory

        // Drop rows whose entry is gone.
        var present = {}
        for (var i = 0; i < entries.length; i++)
            present[entries[i].hid] = true

        for (var j = historyModel.count - 1; j >= 0; j--) {
            if (!present[historyModel.get(j).hid])
                historyModel.remove(j)
        }

        // Insert new rows and refresh the ones that changed in place.
        for (var k = 0; k < entries.length; k++) {
            var entry = entries[k]
            if (k < historyModel.count && historyModel.get(k).hid === entry.hid)
                historyModel.set(k, entry)
            else
                historyModel.insert(k, entry)
        }
    }

    Component.onCompleted: root._syncHistoryModel()

    // Hourly tick drives the derived filter above and the hard prune below.
    SystemClock {
        id: pruneClock
        precision: SystemClock.Hours
        onDateChanged: root.prune()
    }

    FileView {
        id: stateFile
        path: Quickshell.statePath("notifications.json")
        // Read synchronously at startup so history is present on first paint.
        blockLoading: true
        atomicWrites: true

        onLoadFailed: (error) => {
            // First run: create the file from the adapter defaults.
            if (error === FileViewError.FileNotFound) stateFile.writeAdapter()
        }

        // Clear anything that expired while the bar was not running.
        onLoaded: root.prune()

        // FileViewAdapter's base type lacks complete tooling metadata.
        // qmllint disable unresolved-type
        JsonAdapter {
            id: store
            property list<var> history: []
            property bool dnd: false
            // Monotonic id for history entries; independent of the server's
            // per-session notification id (which resets on restart).
            property int seq: 0
        }
        // qmllint enable unresolved-type
    }

    function persist() {
        stateFile.writeAdapter()
    }

    NotificationServer {
        id: server
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
        keepOnReload: true

        onNotification: (notification) => {
            // NotificationAction is not fully described in Quickshell qmltypes.
            // qmllint disable unresolved-type
            var actions = notification.actions
            // qmllint enable unresolved-type
            var hasDefault = false
            if (actions) {
                for (var i = 0; i < actions.length; i++) {
                    if (actions[i].identifier === "default") {
                        hasDefault = true
                        break
                    }
                }
            }

            root._appendHistory(notification.appName || "", notification.summary || "",
                notification.body || "", notification.urgency, "")
            root.unreadCount++

            // Do-Not-Disturb still logs to history and bumps the badge, but no
            // popup appears; close the notification since nothing will show it.
            // An open centre suppresses the popup the same way: the entry is
            // already listed there, so a toast would only duplicate it.
            if (root._store.dnd || root.centreOpen) {
                notification.dismiss()
                return
            }

            notification.tracked = true
            var nid = notification.id
            root.notifMap[nid] = notification
            root._pushToast({
                nid: nid,
                // expireTimeout 0 means "never expire" (spec); -1 leaves the
                // choice to us, and a Critical notification then stays until it
                // is dismissed, matching its history entry never expiring. An
                // explicit timeout from the sender always wins.
                timeout: notification.expireTimeout > 0
                    ? notification.expireTimeout
                    : notification.expireTimeout === 0
                        || notification.urgency === NotificationUrgency.Critical ? 0
                        : root.dismissTimeout,
                appName: notification.appName || "",
                summary: notification.summary || "",
                body: notification.body || "",
                isCritical: notification.urgency === NotificationUrgency.Critical,
                icon: "",
                hasActions: actions !== undefined && actions.length > 0,
                hasDefaultAction: hasDefault
            })
        }
    }

    // ---- Toasts ----

    // Insert a toast at the top and cap the stack, dropping the oldest.
    function _pushToast(fields) {
        toastModel.insert(0, fields)
        while (toastModel.count > root.maxToasts) {
            var lastNid = toastModel.get(toastModel.count - 1).nid
            // Close it for the sender: dropping the row alone leaves the
            // notification open and its sender waiting.
            var evicted = root.notifMap[lastNid]
            if (evicted) evicted.dismiss()
            delete root.notifMap[lastNid]
            toastModel.remove(toastModel.count - 1)
        }
    }

    // Emit a notification we generate ourselves (e.g. prayer times) through the
    // same toast + history path. No live D-Bus object, so no actions; a custom
    // `icon` and `urgency` (0/1/2) may be supplied. `bypassDnd` still shows the
    // popup while Do-Not-Disturb is on (for scheduled alerts the user opted in).
    function notify(opts) {
        var urgency = opts.urgency === undefined ? 1 : opts.urgency
        var icon = opts.icon || ""
        root._appendHistory(opts.appName || "", opts.summary || "",
            opts.body || "", urgency, icon)
        root.unreadCount++
        if (root._store.dnd && opts.bypassDnd !== true) return
        if (root.centreOpen) return
        root._localSeq -= 1
        root._pushToast({
            nid: root._localSeq,
            timeout: urgency >= 2 ? 0 : root.dismissTimeout,
            appName: opts.appName || "",
            summary: opts.summary || "",
            body: opts.body || "",
            isCritical: urgency >= 2,
            icon: icon,
            hasActions: false,
            hasDefaultAction: false
        })
    }

    // Invoking an action calls back to the sender, so it goes through here
    // rather than from the toast that draws the button.
    function invokeAction(action) {
        if (action)
            action.invoke()
    }

    function dismissToast(nid) {
        for (var i = 0; i < toastModel.count; i++) {
            if (toastModel.get(i).nid === nid) {
                var notif = root.notifMap[nid]
                if (notif) notif.dismiss()
                delete root.notifMap[nid]
                toastModel.remove(i)
                return
            }
        }
    }

    // ---- History (persisted) ----

    function _appendHistory(appName, summary, body, urgency, icon) {
        var hid = root._store.seq + 1
        root._store.seq = hid
        var next = root._store.history.slice()
        next.unshift({
            hid: hid,
            appName: appName,
            summary: summary,
            body: body,
            urgency: urgency,
            isCritical: urgency >= 2,
            icon: icon || "",
            time: Date.now(),
            pinned: false
        })
        // Cap the log, evicting the oldest unpinned entry first.
        while (next.length > root.maxHistory) {
            var idx = -1
            for (var i = next.length - 1; i >= 0; i--) {
                if (!next[i].pinned) { idx = i; break }
            }
            if (idx < 0) break
            next.splice(idx, 1)
        }
        root._store.history = next
        root.persist()
    }

    function _ttl(urgency) {
        if (urgency >= 2) return -1                          // Critical: never
        return urgency === 0 ? root.ttlLow : root.ttlNormal  // Low / Normal
    }

    function _expired(e, now) {
        if (e.pinned) return false
        var ttl = root._ttl(e.urgency)
        return ttl >= 0 && (now - e.time) > ttl
    }

    // Hard-delete expired entries + persist; the derived `visibleHistory` hides
    // them in between prunes. Runs on load and hourly.
    function prune() {
        var now = pruneClock.date.getTime()
        var kept = root._store.history.filter((e) => !root._expired(e, now))
        if (kept.length !== root._store.history.length) {
            root._store.history = kept
            root.persist()
        }
    }

    function removeHistory(hid) {
        root._store.history = root._store.history.filter((e) => e.hid !== hid)
        root.persist()
    }

    function togglePin(hid) {
        root._store.history = root._store.history.map((e) =>
            e.hid === hid ? Object.assign({}, e, { pinned: !e.pinned }) : e)
        root.persist()
    }

    // Clear everything except pinned entries.
    function clearHistory() {
        root._store.history = root._store.history.filter((e) => e.pinned)
        root.persist()
    }

    function toggleDnd() {
        root._store.dnd = !root._store.dnd
        root.persist()
    }

    function markAllRead() {
        root.unreadCount = 0
    }
}
