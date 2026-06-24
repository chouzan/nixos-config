pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "../config"

// Shared prayer-time state: one clock, one GeoClue lookup, one notification per
// transition — regardless of how many monitors render the PrayerTimeView.
// Exposes raw times (decimal hours); the view owns formatting.
Singleton {
    id: root

    property real latitude: -6.2
    property real longitude: 107.0

    property string currentPrayer: ""
    property string nextPrayer: ""
    property int elapsedSec: 0
    property int countdownSec: 0
    property date currentTime
    property date nextTime

    property int currentIndex: -1
    property var prayerTimes: []
    property real periodProgress: 0

    property string _cacheKey: ""
    property var _cachedTimes: null
    property real _tomorrowFajr: -1

    // Prayer-time notifications: fire once per genuine transition.
    property bool _prayerReady: false
    property string _lastPrayerNotified: ""

    readonly property var prayerOrder: ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"]

    readonly property bool adhanActive: root.elapsedSec <= 600
    readonly property bool adhanApproaching: root.countdownSec <= 1800

    // ---- Calculation (Fajr 20°, Isha 18°, Shafi'i Asr, +2min ikhtiyat) ----
    readonly property real ikhtiyat: 2 / 60

    function rad(d) { return d * Math.PI / 180 }
    function deg(r) { return r * 180 / Math.PI }

    function sunPosition(jd) {
        var d = jd - 2451545.0
        var g = rad((357.529 + 0.98560028 * d) % 360)
        var q = (280.459 + 0.98564736 * d) % 360
        var l = rad((q + 1.915 * Math.sin(g) + 0.020 * Math.sin(2 * g)) % 360)
        var e = rad(23.439 - 0.00000036 * d)
        var ra = deg(Math.atan2(Math.cos(e) * Math.sin(l), Math.cos(l)))
        var decl = deg(Math.asin(Math.sin(e) * Math.sin(l)))
        var eqt = q / 15 - ra / 15
        if (eqt > 12) eqt -= 24
        if (eqt < -12) eqt += 24
        return { decl: decl, eqt: eqt }
    }

    function hourAngle(lat, decl, angle) {
        var c = (Math.sin(rad(angle)) - Math.sin(rad(lat)) * Math.sin(rad(decl)))
              / (Math.cos(rad(lat)) * Math.cos(rad(decl)))
        if (c < -1 || c > 1) return NaN
        return deg(Math.acos(c)) / 15
    }

    function asrAngle(lat, decl) {
        var alt = deg(Math.atan(1 / (1 + Math.tan(Math.abs(rad(lat) - rad(decl))))))
        return hourAngle(lat, decl, alt)
    }

    function computeTimes(date) {
        var y = date.getFullYear(), m = date.getMonth() + 1, d = date.getDate()
        if (m <= 2) { y--; m += 12 }
        var a = Math.floor(y / 100)
        var b = 2 - a + Math.floor(a / 4)
        var jd = Math.floor(365.25 * (y + 4716))
               + Math.floor(30.6001 * (m + 1)) + d + b - 1524.5

        var sun = sunPosition(jd)
        var tz = -date.getTimezoneOffset() / 60
        var noon = 12 - sun.eqt - root.longitude / 15 + tz

        var ik = root.ikhtiyat
        return {
            "Fajr":    noon - hourAngle(root.latitude, sun.decl, -20) + ik,
            "Sunrise": noon - hourAngle(root.latitude, sun.decl, -0.833) - ik,
            "Dhuhr":   noon + ik,
            "Asr":     noon + asrAngle(root.latitude, sun.decl) + ik,
            "Maghrib": noon + hourAngle(root.latitude, sun.decl, -0.833) + ik,
            "Isha":    noon + hourAngle(root.latitude, sun.decl, -18) + ik
        }
    }

    // Decimal hours on a base day → a concrete Date at minute precision.
    // JS Date normalizes a rounded-up 60 minutes into the next hour.
    function _makeTime(base, decHrs) {
        var d = new Date(base)
        d.setHours(Math.floor(decHrs), Math.round((decHrs % 1) * 60), 0, 0)
        return d
    }

    function update() {
        var now = clock.date
        var key = now.toDateString() + ":" + root.latitude + ":" + root.longitude
        if (root._cacheKey !== key) {
            var raw = computeTimes(now)
            var snapped = {}
            for (var k = 0; k < prayerOrder.length; k++)
                snapped[prayerOrder[k]] = Math.round(raw[prayerOrder[k]] * 60) / 60
            root._cachedTimes = snapped

            var tomorrow = new Date(now)
            tomorrow.setDate(tomorrow.getDate() + 1)
            var ft = computeTimes(tomorrow)
            root._tomorrowFajr = Math.round(ft["Fajr"] * 60) / 60

            root._cacheKey = key
        }

        var times = {}
        for (var k = 0; k < prayerOrder.length; k++)
            times[prayerOrder[k]] = root._cachedTimes[prayerOrder[k]]

        var nowH = now.getHours() + now.getMinutes() / 60 + now.getSeconds() / 3600
        var nowSec = now.getHours() * 3600 + now.getMinutes() * 60 + now.getSeconds()

        var cur = "Isha", nxt = "Fajr"
        for (var i = prayerOrder.length - 1; i >= 0; i--) {
            if (nowH >= times[prayerOrder[i]]) {
                cur = prayerOrder[i]
                nxt = i < prayerOrder.length - 1 ? prayerOrder[i + 1] : "Fajr"
                break
            }
        }
        if (nowH < times["Fajr"]) { cur = "Isha"; nxt = "Fajr" }

        if (cur === "Isha" && nowH >= times["Isha"])
            times["Fajr"] = root._tomorrowFajr

        root.currentPrayer = cur
        root.nextPrayer = nxt

        // When we're past Isha, `times["Fajr"]` already holds tomorrow's Fajr,
        // so that entry must be built on the next calendar day.
        var nextDay = new Date(now)
        nextDay.setDate(nextDay.getDate() + 1)
        var fajrTomorrow = (cur === "Isha" && nowH >= times["Isha"])

        root.currentTime = _makeTime(now, times[cur])
        root.nextTime = _makeTime(nxt === "Fajr" && fajrTomorrow ? nextDay : now, times[nxt])

        var schedule = []
        var curIdx = -1
        for (var j = 0; j < prayerOrder.length; j++) {
            var name = prayerOrder[j]
            var base = (name === "Fajr" && fajrTomorrow) ? nextDay : now
            schedule.push(_makeTime(base, times[name]))
            if (name === cur) curIdx = j
        }
        root.prayerTimes = schedule
        root.currentIndex = curIdx

        var curSec = Math.round(times[cur] * 3600)
        var nxtSec = Math.round(times[nxt] * 3600)

        if (cur === "Isha" && nowH < times["Fajr"])
            root.elapsedSec = nowSec + 86400 - curSec
        else
            root.elapsedSec = nowSec - curSec

        if (nxt === "Fajr" && nowH >= times["Isha"])
            root.countdownSec = nxtSec + 86400 - nowSec
        else
            root.countdownSec = nxtSec - nowSec

        var totalPeriod = root.elapsedSec + root.countdownSec
        root.periodProgress = totalPeriod > 0 ? root.elapsedSec / totalPeriod : 0

        root._checkPrayerTransition(cur)
    }

    // Fire a one-shot notification when a prayer's time arrives. Skips Sunrise
    // (not a prayer), the initial load, and location-driven recomputes — only a
    // genuine transition has a near-zero elapsed time.
    function _checkPrayerTransition(cur) {
        if (cur === root._lastPrayerNotified) return
        root._lastPrayerNotified = cur
        if (!root._prayerReady) return
        if (cur === "" || cur === "Sunrise") return
        if (root.elapsedSec > 90) return
        Notifications.notify({
            appName: "Prayer",
            summary: cur,
            body: "It's time for " + cur + " prayer.",
            urgency: 1,
            icon: "mosque-duotone.svg",
            bypassDnd: true
        })
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
        onDateChanged: root.update()
    }

    Component.onCompleted: {
        root.update()
        root._prayerReady = true
    }

    // ---- GeoClue2 location via where-am-i ----

    Process {
        id: locProc
        command: [Config.whereAmI]
        running: true

        stdout: SplitParser {
            onRead: (line) => {
                var lat = line.match(/Latitude:\s+([-\d.]+)/)
                var lng = line.match(/Longitude:\s+([-\d.]+)/)
                if (lat) root.latitude = parseFloat(lat[1])
                if (lng) { root.longitude = parseFloat(lng[1]); root.update() }
            }
        }
    }
}
