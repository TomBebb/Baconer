import QtQuick 2.12
import org.kde.kirigami 2.13
import "../utils/common.js" as Common
import "../common"

ScrollablePage {
    property alias initialURL: view.initialURL
    property string initialHTML: view.initialHTML
    property EmbeddedWebView webView: view
    objectName: "webViewPage"
    id: page
    title: view.title

    actions {
        contextualActions: [
            Action {
                text: "Refresh"
                iconName: "view-refresh"
                onTriggered: view.reload()
                shortcut: StandardKey.Refresh
            }
        ]
        left: Action {
            text: "Close"
            iconName: "view-close"
            onTriggered:  root.closePage(page)
            shortcut: StandardKey.Close
        }
        right: Action {
            text: "Open externally"
            onTriggered: Qt.openUrlExternally(initialURL)
            visible: initialURL != null
        }
    }

    //Close the drawer with the back button
    onBackRequested: {
        event.accepted = true;
        if (view.canGoBack) {
            view.goBack();
        } else {
            root.pageStack.pop();
        }
    }

    contentItem: EmbeddedWebView {
        id: view
        onUrlChanged: {
            const urlText = url.toString();
            const redditPage = Common.openRedditLink(urlText);

            if (redditPage)
                redditPage.then(page => root.openPage(page));
        }
    }
}
