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
    property bool isSubreddit: url.indexOf("/r/") === 0;
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
        contextualActions: [
            Kirigami.Action {
                text: "Sort"
                iconName: "dialog-filters"
                onTriggered: changeSortOverlay.open()
            },
            Kirigami.Action {
                id: favAction
                iconName: "favorite"
                checkable: true
                text: checked ? qsTr("Unfavorite") : qsTr("Favorite")
                onCheckedChanged: settingsPage.setFav(url, checked)
                visible: isSubreddit

                Component.onCompleted:  updateFav();

                function updateFav() {
                    checked = settingsPage.settings.favorites.has(url);
                }
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


    Connections {
        target: settingsPage.settings

        function onChanged() {
            console.debug("Settings changed");
            favAction.updateFav()
        }
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
            return Promise.resolve(info);
        } else {
            let infoUrl = url;
            if (url.charAt(url.length - 1) == '/')
                infoUrl = infoUrl.substr(0, infoUrl.length - 1);
            return rest.getRedditJSON(`${infoUrl}/about`)
                .then(rawData => info = rawData.data)
                .catch(raw => console.log(`info error: ${Common.toString(raw)}`));
        }
    }
}
