import QtQuick 2.0
import org.kde.kirigami 2.13 as Kirigami
import QtWebView 1.1
import "../actions"

Kirigami.ScrollablePage {
    property string initialURL
    objectName: "webViewPage"
    title: view.title
    actions {
        main: Action {
            text: "Back"
            iconName: "back"
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
