import QtQuick 2.0
import org.kde.kirigami 2.13 as Kirigami

Kirigami.Action {
    text: "Back"
    iconName: "back"
    onTriggered: root.pageStack.pop()
}
