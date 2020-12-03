import QtQuick 2.0

IconAction {
    text: "Back"
    iconName: "arrow-left-b"
    onTriggered: root.pageStack.pop()
}
