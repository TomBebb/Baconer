import QtQuick 2.12
import "../utils/common.js" as Common

Connections {
    function onLinkActivated(link) {
        Common.openLink(link);
    }
}
