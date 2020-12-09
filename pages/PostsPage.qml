import QtQuick 2.1
import org.kde.kirigami 2.13 as Kirigami
import QtQuick.Controls 2.0 as Controls
import QtQuick.Layouts 1.2
import "../utils/common.js" as Common
import "../common"
import "../overlays"

Kirigami.ScrollablePage {
    property ListModel model: postsView.model
    property string url: subsView.currentURL
    property string sortUrl: changeSortOverlay.selectedSortUrl
    property var info: null
    objectName: "postsPage"

    Layout.fillWidth: true

    onSortUrlChanged: refresh()

    Component.onCompleted: {
        refresh();
    }
    actions {
        main: Kirigami.Action {
            text: "Refresh"
            icon.name: "view-refresh"
            onTriggered: refresh(true)
        }
        left: Kirigami.Action {
            text: "Settings"
            iconName: "configuration"
            onTriggered: root.showSettings()
        }
        contextualActions: [
            Kirigami.Action {
                text: "Sort"
                iconName: "dialog-filters"
                onTriggered: changeSortOverlay.open()
            }

        ]
    }

    title: url

    supportsRefreshing: true
    onRefreshingChanged: {
        if (refreshing && !postsModel.loadingPosts)
            refresh(true);
    }

    SortChoiceOverlay {
        id: changeSortOverlay
    }

    Kirigami.CardsListView {
        id: postsView

        model: ListModel {
            id: postsModel
            property string after
            property string before
            property bool loadingPosts
        }
        delegate: PostCard {}
        onContentYChanged: {
            if (atYEnd) {
                rest.loadPostsAfter(url, model)
            }
        }
    }

    function getPostData(index) {
        return postsView.model.get(index);
    }

    onInfoChanged: {
        title = info ? info.title : url;
    }

    function refresh(forceRefresh = false) {
        model.clear();

        postsModel.loadingPosts = true;
        refreshing = true;

        let fullUrl = url;
        if (!Common.endsWith(fullUrl, "/"))
            fullUrl += "/";

        fullUrl += sortUrl;
        rest.loadPosts(fullUrl, postsModel, null, forceRefresh).then(() => {
            refreshing = postsModel.loadingPosts = false;
        });
        if (info && info.url !== url)
            info = null;

        if (info)
            return;
        if (url.length <= 1) {
            info = {
                title: "Frontpage"
            };
        } else {
            let infoUrl = url;
            if (url.charAt(url.length - 1) == '/')
                infoUrl = infoUrl.substr(0, infoUrl.length - 1);
            rest.getRedditJSON(`${infoUrl}/about`)
                .then(rawData => info = rawData.data)
                .catch(raw => console.log(`info error: ${Common.toString(raw)}`));
        }
    }
}
