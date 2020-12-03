import QtQuick 2.1
import org.kde.kirigami 2.11 as Kirigami
import "common.js" as Common

Kirigami.ScrollablePage {
    property var model: postsView.model
    actions {
        main: IconAction {
            text: "Refresh"
            iconName: "refresh"
            onTriggered: reload()
        }
        left: IconAction {
            text: "Settings"
            iconName: "settings"
            onTriggered: {
                Common.createComponent("SettingsPage.qml")
                    .then(page => root.pageStack.push(page))
                    .catch(err => console.error(err))
            }
        }
    }

    title: subsView.currentData ? subsView.currentData.title : "???"
    Kirigami.CardsListView {
        id: postsView
        model: ListModel {
            property string after
            property string before
            property bool loadingPosts
        }
        delegate: PostCard {}
        onContentYChanged: {

            if (atYEnd) {
                const url = subsView.getURL();
                Common.loadPostsAfter(url, model)
            }
        }
    }

    function getPostData(index) {
        return postsView.model.get(index);
    }

    function reload() {
        model.clear();
        Common.loadPosts(subsView.currentData.url, model);
    }
}
