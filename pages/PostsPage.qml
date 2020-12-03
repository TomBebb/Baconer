import QtQuick 2.1
import org.kde.kirigami 2.11 as Kirigami
import "/common.js" as Common
import "../common"
import "../actions"

Kirigami.ScrollablePage {
    property var model: postsView.model
    property string url: subsView.currentURL
    property var info: null
    Component.onCompleted: {
        reload();
    }
    actions {
        main: IconAction {
            text: "Refresh"
            iconName: "refresh"
            onTriggered: reload()
        }
        left: IconAction {
            text: "Settings"
            iconName: "settings"
            onTriggered: root.showSettings()
        }
    }

    title: url
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
                Common.loadPostsAfter(url, model)
            }
        }
    }

    function getPostData(index) {
        return postsView.model.get(index);
    }

    onInfoChanged: {
        title = info.title;
    }

    function reload() {
        model.clear();
        Common.loadPosts(url, model);
        if (info && info.url !== url)
            info = null;

        if (info)
            return;
        if (url && url.length <= 1) {
            info = {
                title: "Frontpage",
                url: url
            };
        } else {
            let infoUrl = url;
            if (url.charAt(url.length - 1) == '/')
                infoUrl = infoUrl.substr(0, infoUrl.length - 1);
            Common.getRedditJSON(`${infoUrl}/about`)
                .then(rawData => info = rawData.data)
                .catch(raw => console.log(`info error: ${Common.toString(raw)}`));
        }
    }
}
