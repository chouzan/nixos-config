import Quickshell
import QtQuick
import "components/audio"
import "components/bar"
import "components/notifications"

ShellRoot {
    Bar {}
    VolumeOSD {}
    NotificationToast {}
}
