import QtQuick 2.0
import "../utils/common.js" as Common

Connections {
    function onLinkActivated(link) {
        Common.openLink(link);
    }
}
