import QtQuick 2.0
import org.kde.kirigami 2.11 as Kirigami
import QtWebView 1.1
import "../actions"

Kirigami.ScrollablePage {
    property string initialURL
    title: view.title
    actions {
        main: IconAction {
            text: "Back"
            iconName: "arrow-left-b"
            onTriggered: {
                if (view.canGoBack) {
                    view.goBack();
                } else {
                    root.pageStack.pop();
                }
            }
        }
    }

    contentItem: WebView {
        id: view
    }
    Component.onCompleted: view.url = initialURL
}
