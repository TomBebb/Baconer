import QtQuick 2.0
import QtWebView 1.1
import org.kde.kirigami 2.13
import "../utils/common.js" as Common

ScrollablePage {
    property string initialURL
    objectName: "webViewPage"
    id: page
    title: view.title
    actions.contextualActions: [
        Action {
            text: "Refresh"
            iconName: "view-refresh"
            onTriggered: view.reload()
        }
    ]

    //Close the drawer with the back button
    onBackRequested: {
        event.accepted = true;
        if (view.canGoBack) {
            view.goBack();
        } else {
            root.pageStack.pop();
        }
    }

    contentItem: WebView {
        id: view
        onUrlChanged: {
            const urlText = url.toString();
            const redditPage = Common.openRedditLink(urlText);

            if (redditPage)
                redditPage.then(page => root.openPage(page));
        }
    }
    Component.onCompleted: {
        view.url = initialURL;

        console.log("URL opened: "+view.url)
    }
}
