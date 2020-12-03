import QtQuick 2.0
import org.kde.kirigami 2.11 as Kirigami
import Ionicon 1.0

Kirigami.Action {
    property string iconName
    id: action
    displayComponent: Ionicon {
        source: iconName
        size: height

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton

            onClicked: {
                action.trigger(this)

            }
        }
    }
}
