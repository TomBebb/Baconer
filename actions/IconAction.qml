import QtQuick 2.0
import org.kde.kirigami 2.13 as Kirigami
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0 as Controls
import Ionicon 1.0
import "/common.js" as Common

Kirigami.Action {
    property string iconName
    id: action
    displayComponent: RowLayout {
        Ionicon {
            source: iconName
            size: height
        }
        Controls.Label {
            text: action.text
            visible: Common.isNonEmptyString(action.text) && !root.assumeMobile
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton

            onClicked: {
                action.trigger(this)

            }
        }
    }
}
