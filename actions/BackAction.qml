import QtQuick 2.0
import org.kde.kirigami 2.13 as Kirigami

IconAction {
    text: "Back"
    iconName: "arrow-left-b"
    onTriggered: root.pageStack.pop()
}
