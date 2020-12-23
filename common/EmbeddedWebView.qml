import QtQuick 2.12
import QtWebView 1.1

WebView {
    property string initialURL
    property string initialHTML

    Component.onCompleted: {
        console.debug(`Web view: url=${initialURL}, html=${initialHTML}, width = ${width}, height = ${height}`);
        if (initialHTML != null) {
            loadHtml(initialHTML, initialURL);
        } else {
            url = initialURL;
        }
    }
}
